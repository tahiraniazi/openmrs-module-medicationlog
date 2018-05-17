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

import java.util.Date;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Drug;
import org.openmrs.DrugOrder;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.OrderFrequency;
import org.openmrs.Patient;
import org.openmrs.SimpleDosingInstructions;
import org.openmrs.User;
import org.openmrs.api.APIException;
import org.openmrs.api.ConceptService;
import org.openmrs.api.OrderContext;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.util.DateUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
@Controller
@RequestMapping(value = "/module/medicationlog/order/")
public class MedicationOrderController {
	
	private static final Log log = LogFactory.getLog(MedicationPortletController.class);
	
	//String error = "";
	
	/*
	 * saves a new drug order
	 */
	@RequestMapping(value = "addDrugOrder.form", method = RequestMethod.POST)
	public String addDrugOrder(ModelMap model, @RequestParam(value = "patientId", required = true) Integer patientId,
	        @RequestParam(value = "currentUser", required = false) String currentUserId,
	        @RequestParam(value = "drugId", required = true) Integer drugId,
	        @RequestParam(value = "drugName", required = true) String drugName,
	        @RequestParam(value = "drugSelection", required = true) String drugSelection,
	        @RequestParam(value = "patientEncounter", required = true) Integer encounterId,
	        @RequestParam(value = "dose", required = true) Double dose,
	        @RequestParam(value = "doseUnit", required = true) Integer doseUnit,
	        @RequestParam(value = "frequency", required = true) Integer frequency,
	        @RequestParam(value = "route", required = true) Integer route,
	        @RequestParam(value = "dosingInstructions", required = false) String dosingInstruction,
	        @RequestParam(value = "startDateDrug", required = true) Date startDateDrug,
	        @RequestParam(value = "duration", required = true) int duration,
	        @RequestParam(value = "durationUnit", required = true) Integer durationUnit,
	        @RequestParam(value = "asNeeded", required = false) String asNeeded,
	        @RequestParam(value = "orderReason", required = false) Integer orderReason,
	        @RequestParam(value = "orderReasonNonCoded", required = false) String orderReasonNonCoded,
	        @RequestParam(value = "adminInstructions", required = false) String adminInstructions,
	        @RequestParam(value = "returnPagee", required = true) String returnPage) {
		
		try {
			DrugOrder drugOrder = saveDrugOrder(currentUserId, patientId, drugId, drugName, drugSelection, encounterId,
			    dose, doseUnit, frequency, route, dosingInstruction, startDateDrug, duration, durationUnit, asNeeded,
			    orderReason, orderReasonNonCoded, adminInstructions);
			
			// save drug order
			OrderContext orderContext = new OrderContext();
			Context.getOrderService().saveOrder(drugOrder, orderContext);
			String saved = "Drug Order saved successfully";
			model.addAttribute("saved", saved);
		}
		catch (APIException e) {
			e.printStackTrace();
			String error = "Unable to create Drug Order. \n";
			if (e.getMessage().equals("Order.cannot.have.more.than.one"))
				error += "Cannot have more than one active order for the same orderable and care setting at same time.";
			else
				error += e.getMessage();
			
			model.addAttribute("error", error);
			// request.setAttribute("error", error);
			// model.put("error", error);
			// bindingResult.reject("nocode", null, error);
		}
		
		Logger.getAnonymousLogger().info("### =================== Print return page =======================");
		Logger.getAnonymousLogger().info(returnPage);
		//		return "redirect";
		return "redirect:" + returnPage;
	}
	
	private DrugOrder saveDrugOrder(String currentUserid, Integer patientId, Integer drugId, String drugName,
	        String drugSelection, Integer encounterId, Double dose, Integer doseUnit, Integer frequency, Integer route,
	        String dosingInstructions, Date startDateDrug, int duration, Integer durationUnit, String asNeeded,
	        Integer orderReason, String orderReasonNonCoded, String adminInstructions) {
		
		DrugOrder drugOrder = new DrugOrder();
		
		try {
			ConceptService conceptService = Context.getConceptService();
			
			Patient patient = Context.getPatientService().getPatient(patientId);
			User currentUser = Context.getUserService().getUserByUsername(currentUserid);
			org.openmrs.Provider provider = Context.getProviderService()
			        .getProvidersByPerson(currentUser.getPerson(), false).iterator().next();
			drugOrder.setPatient(patient);
			
			Encounter encounter = null;
			
			Logger.getAnonymousLogger().info("### ======================= Encounter ID: " + encounterId);
			// if encounter is null, create new encounter of type 'Drug Prescription'
			if (encounterId == null) {
				EncounterType encounterTypeObj = Context.getEncounterService().getEncounterType("Drug Prescription");
				
				// setting encounter
				encounter = new Encounter();
				encounter.setPatient(patient);
				
				encounter.setDateCreated(new Date());
				encounter.setEncounterType(encounterTypeObj);
				encounter.setCreator(currentUser);
				encounter.setProvider(Context.getEncounterService().getEncounterRoleByName("Unknown"), provider);
				if (DateUtil.beforeSecondDate(startDateDrug, new Date()))
					encounter.setEncounterDatetime(startDateDrug);
				else
					encounter.setEncounterDatetime(new Date());
				
				encounter.setDateCreated(new Date());
				encounter = Context.getEncounterService().saveEncounter(encounter);
				
			} // else fetch the one specified by the user
			else {
				encounter = Context.getEncounterService().getEncounter(encounterId);
			}
			
			// setting encounter to drug order
			drugOrder.setEncounter(encounter);
			drugOrder.setDateActivated(startDateDrug);
			
			Logger.getAnonymousLogger().info("### =============================== Drug Selection Criteria:" + drugSelection);
			Drug orderDrug = null;
			
			if (drugSelection == null) {
				if (drugId != null)
					drugSelection = "BY DRUG";
				else if (drugName != null && !drugName.isEmpty())
					drugSelection = "BY DRUG SET";
			}
			
			if (drugSelection.equals("BY DRUG") && drugId != null) {
				orderDrug = conceptService.getDrug(drugId);
			} else if (drugSelection.equals("BY DRUG SET") && (drugName != null && !drugName.isEmpty())) {
				orderDrug = conceptService.getDrug(drugName);
			}
			
			drugOrder.setDrug(orderDrug);
			Logger.getAnonymousLogger().info(
			    "### =============================== Drug Concept:" + orderDrug.getConcept().getConceptId());
			drugOrder.setConcept(orderDrug.getConcept());
			drugOrder.setDose(dose);
			drugOrder.setDoseUnits(conceptService.getConcept(doseUnit));
			OrderFrequency orderFrequency = Context.getOrderService().getOrderFrequencyByConcept(
			    conceptService.getConcept(frequency));
			
			if (orderFrequency == null) {
				
				OrderFrequency newOrderFrequency = new OrderFrequency();
				newOrderFrequency.setConcept(Context.getConceptService().getConcept(frequency));
				Context.getOrderService().saveOrderFrequency(newOrderFrequency);
				
				drugOrder.setFrequency(newOrderFrequency);
				
			} else {
				drugOrder.setFrequency(orderFrequency);
			}
			
			drugOrder.setRoute(conceptService.getConcept(route));
			
			if (dosingInstructions != null && !dosingInstructions.isEmpty())
				drugOrder.setDosingInstructions(dosingInstructions);
			
			drugOrder.setDuration(duration);
			drugOrder.setDurationUnits(conceptService.getConcept(durationUnit));
			drugOrder.setNumRefills(0);
			drugOrder.setQuantity(0.0);
			drugOrder.setQuantityUnits(conceptService.getConcept(doseUnit));
			
			String asNeededValue = asNeeded;
			
			if (asNeededValue != null) {
				drugOrder.setAsNeeded(true);
			} else {
				drugOrder.setAsNeeded(false);
			}
			
			drugOrder.setCareSetting(Context.getOrderService().getCareSettingByName("Outpatient")); //Fetch Outpatient care setting
			
			// setting provider
			drugOrder.setOrderer(provider);
			drugOrder.setDosingType(SimpleDosingInstructions.class);
			
			if (orderReason != null)
				drugOrder.setOrderReason(Context.getConceptService().getConcept(orderReason));
			
			if (orderReasonNonCoded != null && !orderReasonNonCoded.isEmpty())
				drugOrder.setOrderReasonNonCoded(orderReasonNonCoded);
			
			if (adminInstructions != null && !adminInstructions.isEmpty())
				drugOrder.setInstructions(adminInstructions);
		}
		catch (APIException e) {
			e.printStackTrace();
			Logger.getAnonymousLogger().info("### =================== Exception: " + e.getMessage());
		}
		
		return drugOrder;
	}
	
	@RequestMapping(value = "stopOrder", method = RequestMethod.GET)
	public void stopOrder(@RequestParam(value = "orderId", required = true) Integer orderId, HttpServletResponse response) {
		
		//			Patient patient = Context.getPatientService().getPatient(patientId);
		
	}
}
