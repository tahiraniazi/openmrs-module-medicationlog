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
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xpath.operations.Mod;
import org.codehaus.jackson.map.ObjectMapper;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import org.hibernate.procedure.spi.ParameterRegistrationImplementor;
import org.openmrs.Concept;
import org.openmrs.Drug;
import org.openmrs.DrugOrder;
import org.openmrs.Encounter;
import org.openmrs.Order;
import org.openmrs.Order.Action;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.resources.DrugOrderWrapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;


/**
 * @author tahira.niazi@ihsinformatics.com
 */
@Controller
@RequestMapping(value = "/module/medicationlog/ajax/")
public class MedicationAjaxController {
	
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
		
		// TODO: complete this
		JsonObject orderDetails = new JsonObject();
		Order searchedOrder = Context.getOrderService().getOrder(drugOrderId);
		DrugOrder searchedDrugOrder = (DrugOrder) searchedOrder;
		
		// one of the orders from current regimen
		if(searchedOrder.isActive()) {
			
			if(searchedOrder.getPreviousOrder() == null) {

				// single order case, no previous order exists
				DrugOrderWrapper singleOrder = construcViewOrderObject(searchedOrder, searchedDrugOrder);
				orderDetails.add("singleOrder", new Gson().toJsonTree(singleOrder));
			}
			else if(searchedOrder.getPreviousOrder() != null && searchedOrder.getAction().equals(Action.REVISE)) {
				
				// it is the order that was REVISED and resulted in searchedOrder object
				Order parentOrder = searchedOrder.getPreviousOrder();
				DrugOrder parentDrugOrder = (DrugOrder) parentOrder;
				DrugOrderWrapper originalOrder = construcViewOrderObject(parentOrder, parentDrugOrder);
				orderDetails.add("orginalOrder", new Gson().toJsonTree(originalOrder));
			}
		}  
		else {
			// one of the orders from completed regimen/ discontinued
			// capture the discontinued fields also
			
		}
		return orderDetails.toString();
	}
	
	private DrugOrderWrapper construcViewOrderObject (Order order, DrugOrder drugOrder) {
		
		DrugOrderWrapper drugOrderWrapper = new DrugOrderWrapper(order.getOrderId(), order.getEncounter(), order.getDateCreated(), 
				order.getOrderer().getCreator().getUsername(), order.getUuid(), drugOrder.getDrug().getDrugId(), 
				drugOrder.getDrug().getConcept().getDisplayString().toLowerCase(), drugOrder.getDose(), drugOrder.getDoseUnits()
		        .getDisplayString().toLowerCase(), drugOrder.getFrequency().getConcept().getDisplayString().toLowerCase(),
		        drugOrder.getRoute().getDisplayString().toLowerCase(), drugOrder.getDuration(), drugOrder.getDurationUnits()
		                .getDisplayString().toLowerCase(), order.getDateActivated());
		
		
		if (order.getAutoExpireDate() != null) 
			drugOrderWrapper.setScheduledStopDate(order.getAutoExpireDate());
		
		if (order.getInstructions() != null && !order.getInstructions().isEmpty()) 
			drugOrderWrapper.setInstructions(order.getInstructions());
		
		if (order.getDateStopped() != null) 
			drugOrderWrapper.setDateStopped(order.getDateStopped());
		
		if (drugOrder.getAsNeeded() != null) 
			drugOrderWrapper.setAsNeeded(drugOrder.getAsNeeded());
		
		// capture the discontinue reason if exists
		
		return drugOrderWrapper;
	}
	
}
