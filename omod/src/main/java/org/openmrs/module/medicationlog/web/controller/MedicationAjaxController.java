/**
 * Copyright(C) 2018 Interactive Health Solutions, Pvt. Ltd.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License (GPLv3), or any later version.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Interactive Health Solutions, info@ihsinformatics.com
 * You can also access the license on the internet at the address: http://www.gnu.org/licenses/gpl-3.0.html
 * Interactive Health Solutions, hereby disclaims all copyright interest in this program written by the contributors.
 * Contributors: Tahira Niazi
 */
package org.openmrs.module.medicationlog.web.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.WordUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Drug;
import org.openmrs.DrugOrder;
import org.openmrs.Order;
import org.openmrs.Person;
import org.openmrs.Order.Action;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.resources.DrugOrderWrapper;
import org.openmrs.module.medicationlog.util.ExclusionStrategyUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
@Controller
@RequestMapping(value = "/module/medicationlog/ajax/")
public class MedicationAjaxController {
	
	final char[] delimiters = { ' ', '_' };
	
	private Log log = LogFactory.getLog(this.getClass());
	
	@RequestMapping(value = "getDrugsByDrugSet", method = RequestMethod.GET)
	public void getDrugsByDrugSet(@RequestParam(value = "conceptId", required = true) String conceptId,
	        HttpServletResponse response) {
		
		List<Concept> drugConcepts;
		List<Concept> nonRetiredDrugs = new ArrayList<Concept>();
		Concept drugSetConcept = Context.getConceptService().getConcept(Integer.parseInt(conceptId));
		drugConcepts = drugSetConcept.getSetMembers();
		
		// can not remove non-retired concepts directly from drugConcepts as it
		// is a non-modifiable list
		// also, only add concept if its class is drug and a drug object is also associated with that concept
		for (Concept concept : drugConcepts) {
			if (!concept.getRetired()
			        && concept.getConceptClass() == Context.getConceptService().getConceptClassByName("Drug")
			        && Context.getConceptService().getDrugsByConcept(concept).size() > 0) {
				nonRetiredDrugs.add(concept);
			}
		}
		
		List<Map<String, String>> drugs = new ArrayList<Map<String, String>>();
		for (Concept drugConcept : nonRetiredDrugs) {
			
			Map<String, String> info = new HashMap<String, String>();
			info.put("id", Integer.toString(drugConcept.getId()));
			info.put("name", drugConcept.getFullySpecifiedName(Locale.ENGLISH).getName());
			
			drugs.add(info);
		}
		
		ObjectMapper mapper = new ObjectMapper();
		try {
			mapper.writeValue(response.getWriter(), drugs);
		}
		catch (Exception e) {
			log.error("Error occurred while writing to response: ", e);
		}
	}
	
	@RequestMapping(value = "getAllDrugs", method = RequestMethod.GET)
	public void getAllDrugs(HttpServletResponse response) {
		
		List<Drug> drugList = Context.getConceptService().getAllDrugs();
		List<Map<String, String>> drugs = new ArrayList<Map<String, String>>();
		
		for (Drug drug : drugList) {
			Concept drugConcept = drug.getConcept();
			if (drugConcept != null && !drugConcept.getRetired()) {
				Map<String, String> info = new HashMap<String, String>();
				info.put("id", Integer.toString(drug.getDrugId()));
				info.put("name", drugConcept.getFullySpecifiedName(Locale.ENGLISH).getName());
				drugs.add(info);
			}
		}
		
		ObjectMapper mapper = new ObjectMapper();
		try {
			mapper.writeValue(response.getWriter(), drugs);
		}
		catch (Exception e) {
			log.error("Error occurred while writing to response: ", e);
		}
	}
	
	@RequestMapping(value = "getDrugOrder", method = RequestMethod.GET)
	@ResponseBody
	public String getDrugOrderDetails(@RequestParam(value = "drugOrderId", required = true) int drugOrderId,
	        @RequestParam(value = "patientId", required = true) int patientId, Model model) {
		
		JsonObject orderDetails = new JsonObject();
		GsonBuilder builder = new GsonBuilder().setExclusionStrategies(new ExclusionStrategyUtil());
		//builder.registerTypeAdapterFactory(HibernateProxyTypeAdapter.FACTORY);
		Gson gson = builder.create();
		
		try {
			Order searchedOrder = Context.getOrderService().getOrder(drugOrderId);
			DrugOrder searchedDrugOrder = (DrugOrder) searchedOrder;
			
			// putting the actual order that was clicked to view
			DrugOrderWrapper singleOrder = constructViewOrderObject(searchedOrder, searchedDrugOrder);
			
			if (searchedOrder.getPreviousOrder() != null && searchedOrder.getAction().equals(Action.REVISE)) {
				
				// it is the order that was REVISED and resulted in searchedOrder object
				Order parentOrder = searchedOrder.getPreviousOrder();
				DrugOrder parentDrugOrder = (DrugOrder) parentOrder;
				DrugOrderWrapper originalOrder = constructViewOrderObject(parentOrder, parentDrugOrder);
				/*GsonBuilder b = new GsonBuilder();
				b.registerTypeAdapterFactory(HibernateProxyTypeAdapter.FACTORY);
				Gson gson = b.create();*/
				String revisedOrderString = gson.toJson(originalOrder);
				Logger.getAnonymousLogger().log(Level.INFO, revisedOrderString);
				orderDetails.addProperty("revisedOrder", revisedOrderString);
			}
			
			String singleOrderString = gson.toJson(singleOrder);
			orderDetails.addProperty("singleOrder", singleOrderString);
		}
		catch (APIException e) {
			e.printStackTrace();
		}
		return orderDetails.toString();
	}
	
	private DrugOrderWrapper constructViewOrderObject(Order order, DrugOrder drugOrder) {
		
		DrugOrderWrapper drugOrderWrapper = new DrugOrderWrapper(order.getOrderId(), order.getEncounter().getEncounterType()
		        .getName(), Context.getEncounterService().getEncounter(order.getEncounter().getEncounterId()),
		        order.getDateCreated(), order.getOrderer().getName(), order.getUuid(), drugOrder.getDrug().getDrugId(),
		        drugOrder.getDrug().getConcept().getDisplayString().toLowerCase(), (int) Math.round(drugOrder.getDose()),
		        drugOrder.getDoseUnits().getDisplayString().toLowerCase(), drugOrder.getFrequency().getConcept()
		                .getDisplayString().toLowerCase(), drugOrder.getRoute().getDisplayString().toLowerCase(),
		        drugOrder.getDuration(), drugOrder.getDurationUnits().getDisplayString().toLowerCase(),
		        order.getDateActivated());
		
		if (order.getAutoExpireDate() != null)
			drugOrderWrapper.setAutoExpireDate(order.getAutoExpireDate());
		
		if (order.getInstructions() != null && !order.getInstructions().isEmpty())
			drugOrderWrapper.setInstructions(order.getInstructions());
		
		if (order.getDateStopped() != null)
			drugOrderWrapper.setDateStopped(order.getDateStopped());
		
		if (drugOrder.getDosingInstructions() != null && !drugOrder.getDosingInstructions().isEmpty())
			drugOrderWrapper.setDosingInstructions(drugOrder.getDosingInstructions());
		
		if (drugOrder.getAsNeeded() != null)
			drugOrderWrapper.setAsNeeded(drugOrder.getAsNeeded());
		
		if (drugOrder.getOrderReasonNonCoded() != null)
			drugOrderWrapper.setOrderReason(drugOrder.getOrderReasonNonCoded());
		
		// capture the discontinue reason if exists
		Order discontinuationOrder = Context.getOrderService().getDiscontinuationOrder(order);
		if (discontinuationOrder != null && discontinuationOrder.getOrderReason() != null)
			drugOrderWrapper.setDiscontinueReason(WordUtils.capitalizeFully(discontinuationOrder.getOrderReason()
			        .getDisplayString(), delimiters));
		
		return drugOrderWrapper;
	}
	
	@RequestMapping(value = "getPatientUuid", method = RequestMethod.GET)
	@ResponseBody
	public String getDrugOrderDetails(@RequestParam(value = "patientId", required = true) int patientId, Model model) {
		
		JsonObject orderDetails = new JsonObject();
		
		try {
			
			Person person = Context.getPersonService().getPerson(patientId);
			orderDetails.addProperty("patientUuid", person.getUuid());
		}
		catch (APIException e) {
			e.printStackTrace();
		}
		return orderDetails.toString();
	}
}
