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

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.Drug;
import org.openmrs.DrugOrder;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Order;
import org.openmrs.OrderFrequency;
import org.openmrs.Patient;
import org.openmrs.SimpleDosingInstructions;
import org.openmrs.User;
import org.openmrs.api.APIException;
import org.openmrs.api.ConceptService;
import org.openmrs.api.OrderContext;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.MedicationLogActivator;
import org.openmrs.web.WebConstants;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author tahira.niazi@ihsinformatics.com
 */

@Controller
@RequestMapping(value = "module/medicationlog/singleDrugOrder")
public class SingleDrugOrderController {
	
	public static final String SQL_DATE = "yyyy-MM-dd";
	
	SimpleDateFormat sdf = new SimpleDateFormat(SQL_DATE);
	
	protected final Log log = LogFactory.getLog(getClass());
	
	@RequestMapping(method = RequestMethod.GET)
	public void showSingleDrugOrderForm(HttpServletRequest request, Map<String, Object> model) {
		
		// order.durationUnitsConceptUuid > units
		List<Concept> durationUnits = Context.getOrderService().getDurationUnits();
		log.info("Duration unit concepts are " + durationUnits);
		model.put("durationUnits", durationUnits);
		
		// frequencies
		
		// order.drugRoutesConceptUuid > routes
		List<Concept> routes = Context.getOrderService().getDrugRoutes();
		log.info("Routes concepts are " + routes);
		model.put("routes", routes);
		
		// order.drugDosingUnitsConceptUuid > 162384 > dose units
		List<Concept> doseUnits = Context.getOrderService().getDrugDosingUnits();
		log.info("Dose unit concepts are " + doseUnits);
		model.put("doseUnits", doseUnits);
		
		// MEDICATION FREQUENCY > 160855 > 160855AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
		String frequencyUuid = Context.getAdministrationService().getGlobalProperty(
		    "medication.medicationFrequenciesConceptUuid");
		Concept frequencySet = Context.getConceptService().getConceptByUuid(frequencyUuid);
		if (frequencySet != null && frequencySet.getSetMembers().size() > 0) {
			List<Concept> frequencies = frequencySet.getSetMembers();
			log.info("Frequency concepts are " + frequencies);
			model.put("frequencies", frequencies);
		}
		
		String orderReasonUuid = Context.getAdministrationService().getGlobalProperty(
		    MedicationLogActivator.MEDICATION_ORDER_REASON_CONCEPT_UUID);
		
		log.info("===================== Order reason UUid is " + orderReasonUuid);
		log.info("==============================================================");
		
		if (orderReasonUuid != null && !orderReasonUuid.isEmpty()) {
			Concept orderReason = Context.getConceptService().getConceptByUuid(orderReasonUuid);
			if (orderReason != null && orderReason.getAnswers(false).size() > 0) {
				Collection<ConceptAnswer> reasonCollection = orderReason.getAnswers(false);
				ArrayList<Concept> reasons = new ArrayList<Concept>();
				
				for (ConceptAnswer reason : reasonCollection) {
					reasons.add(reason.getAnswerConcept());
					
				}
				log.info("============ Order reason concepts are " + reasons);
				model.put("orderReasons", reasons);
			}
		}
		
		// reading drug set classes global property (it indicates the types of
		// concept sets required e.g LabSet, ConvSet). Get the comma-separated
		// values and fetch these concepts by class and then generate the final
		// list of the drug set concepts
		
		String drugClasses = Context.getAdministrationService().getGlobalProperty(
		    MedicationLogActivator.MEDICATION_DRUG_SETS_PROPERTY);
		
		List<String> classes;
		List<Concept> drugSets = new ArrayList<Concept>();
		
		// search drug sets based on drug classes specified in advance settings
		if (drugClasses != null && !drugClasses.isEmpty()) {
			if (drugClasses.contains(",")) {
				classes = Arrays.asList(drugClasses.split(","));
			} else {
				classes = new ArrayList<String>();
				classes.add(drugClasses);
			}
			drugSets = getDrugSets(classes);
		}
		// else search concept sets for all Set classes like ConvSet, MedSet
		// etc.
		else {
			drugClasses = "LabSet, MedSet, ConvSet";
			classes = Arrays.asList(drugClasses.split(",").toString().trim());
			drugSets = getDrugSets(classes);
		}
		
		model.put("drugSets", drugSets);
		
		//* fetching patient encounters for linking with drug order
		int patientId = Integer.parseInt(request.getParameter("patientId"));
		
		// put patient ID in the model
		model.put("patientId", patientId);
		
		Patient patient = Context.getPatientService().getPatient(patientId);
		// encounters in ASC order by encounter date time
		List<Encounter> allEncounters = Context.getEncounterService().getEncountersByPatient(patient);
		
		// reversing the list to get encounters in DESC order by encounter date time
		List<Encounter> descEncounters = allEncounters.subList(0, allEncounters.size());
		Collections.reverse(descEncounters);
		
		if (descEncounters.size() > 10)
			descEncounters = new ArrayList<Encounter>(descEncounters.subList(0, 10));
		else
			descEncounters = new ArrayList<Encounter>(descEncounters.subList(0, descEncounters.size()));
		
		List<Map<String, String>> encounters = new ArrayList<Map<String, String>>();
		for (Encounter encounter : descEncounters) {
			Map<String, String> encounterInfo = new HashMap<String, String>();
			encounterInfo.put("encounterId", Integer.toString(encounter.getEncounterId()));
			encounterInfo.put("encounterName", encounter.getEncounterType().getName());
			encounterInfo.put("encounterDate", sdf.format(encounter.getEncounterDatetime()));
			encounters.add(encounterInfo);
		}
		
		model.put("encounters", encounters);
		
		// put current user ID in the model
		model.put("currentUserId", Context.getAuthenticatedUser());
		
		// putting Order Stop Reasons in model
		String orderStoppedReasonUuid = Context.getAdministrationService().getGlobalProperty(
		    MedicationLogActivator.MEDICATION_REASON_ORDER_STOPPED_UUID);
		
		if (orderStoppedReasonUuid != null && !orderStoppedReasonUuid.isEmpty()) {
			Concept orderStoppedReason = Context.getConceptService().getConceptByUuid(orderStoppedReasonUuid);
			if (orderStoppedReason != null && orderStoppedReason.getAnswers(false).size() > 0) {
				Collection<ConceptAnswer> stoppedReasonCollection = orderStoppedReason.getAnswers(false);
				ArrayList<Concept> stoppedReasons = new ArrayList<Concept>();
				
				for (ConceptAnswer reason : stoppedReasonCollection) {
					stoppedReasons.add(reason.getAnswerConcept());
					
				}
				log.info("============ Order reason concepts are " + stoppedReasons);
				model.put("orderStoppedReasons", stoppedReasons);
			}
		}
		
		if (request.getParameter("orderId") != null) {
			int orderId = Integer.parseInt(request.getParameter("orderId"));
			model.put("requestedOrder", Context.getOrderService().getOrder(orderId));
			
			if (request.getParameter("operation") != null)
				model.put("operation", request.getParameter("operation"));
			
		}
	}
	
	/*
	 * saves a new drug order
	 */
	@RequestMapping(value = "/addDrugOrder.form", method = RequestMethod.POST)
	public String addDrugOrder(ModelMap model, HttpServletRequest request,
	        @RequestParam(value = "orderId", required = false) Integer orderId,
	        @RequestParam(value = "patientId", required = true) Integer patientId,
	        @RequestParam(value = "currentUserId", required = false) String currentUserId,
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
	        @RequestParam(value = "operation", required = false) String operation,
	        @RequestParam(value = "returnPagee", required = true) String returnPage) {
		
		try {
			DrugOrder drugOrder = constructDrugOrderObject(null, currentUserId, patientId, drugId, drugName, drugSelection,
			    encounterId, dose, doseUnit, frequency, route, dosingInstruction, startDateDrug, duration, durationUnit,
			    asNeeded, orderReason, orderReasonNonCoded, adminInstructions);
			
			OrderContext orderContext = new OrderContext();
			if (orderId != null) {
				
				Order existing = Context.getOrderService().getOrder(orderId);
				if (existing != null && operation.equals("REVISE")) {
					// revise order, stops the active order and assigns REVISE action to new order
					Order revisedOrder = existing.cloneForRevision();
					DrugOrder revisedDrugOrder = (DrugOrder) revisedOrder;
					
					// calling constructDrugOrderObject(...) to include any updated information in the drugOrder and 
					// catching the same revised order object back
					revisedDrugOrder = constructDrugOrderObject(revisedDrugOrder, currentUserId, patientId, drugId,
					    drugName, drugSelection, encounterId, dose, doseUnit, frequency, route, dosingInstruction,
					    startDateDrug, duration, durationUnit, asNeeded, orderReason, orderReasonNonCoded, adminInstructions);
					
					Context.getOrderService().saveOrder((Order) revisedDrugOrder, null);
				}
				
				if (operation.equals("RENEW")) {
					// does not assign RENEW action
					Context.getOrderService().saveOrder(drugOrder, orderContext);
				}
				
			} else
				Context.getOrderService().saveOrder(drugOrder, orderContext);
		}
		catch (APIException e) {
			e.printStackTrace();
			String error = "Unable to create Drug Order. \n";
			if (e.getMessage().equals("Order.cannot.have.more.than.one"))
				error += "Cannot have more than one active order for the same orderable and care setting at same time.";
			else
				error += e.getMessage();
			
			model.addAttribute("error", error);
			model.addAttribute("patientId", patientId);
			
			return "redirect:/module/medicationlog/singleDrugOrder.form";
			
		}
		
		// save alert
		request.getSession().setAttribute(WebConstants.OPENMRS_MSG_ATTR, "medication.drugOrder.saved");
		Logger.getAnonymousLogger().info(returnPage);
		// return "redirect";
		return "redirect:" + returnPage;
	}
	
	private DrugOrder constructDrugOrderObject(DrugOrder drugOrder, String currentUserid, Integer patientId, Integer drugId,
	        String drugName, String drugSelection, Integer encounterId, Double dose, Integer doseUnit, Integer frequency,
	        Integer route, String dosingInstructions, Date startDateDrug, int duration, Integer durationUnit,
	        String asNeeded, Integer orderReason, String orderReasonNonCoded, String adminInstructions) {
		
		if (drugOrder == null)
			drugOrder = new DrugOrder();
		
		try {
			ConceptService conceptService = Context.getConceptService();
			
			Patient patient = Context.getPatientService().getPatient(patientId);
			User currentUser = Context.getUserService().getUserByUsername(currentUserid);
			org.openmrs.Provider provider = Context.getProviderService()
			        .getProvidersByPerson(currentUser.getPerson(), false).iterator().next();
			
			// do not set patient in case of REVISE object
			if (drugOrder.getPatient() == null)
				drugOrder.setPatient(patient);
			
			Encounter encounter = null;
			
			Logger.getAnonymousLogger().info("### ======================= Encounter ID: " + encounterId);
			// if encounter is null, create new encounter of type 'Drug
			// Prescription'
			if (encounterId == null) {
				EncounterType encounterTypeObj = Context.getEncounterService().getEncounterType("Drug Prescription");
				
				// setting encounter
				encounter = new Encounter();
				encounter.setPatient(patient);
				
				encounter.setDateCreated(new Date());
				encounter.setEncounterType(encounterTypeObj);
				encounter.setCreator(currentUser);
				encounter.setProvider(Context.getEncounterService().getEncounterRoleByName("Unknown"), provider);
				if (startDateDrug.compareTo(new Date()) < 0) // before second
				                                             // date
					encounter.setEncounterDatetime(startDateDrug);
				else
					encounter.setEncounterDatetime(new Date());
				
				encounter.setDateCreated(new Date());
				encounter = Context.getEncounterService().saveEncounter(encounter);
				
			} // else fetch the one specified by the user
			else {
				encounter = Context.getEncounterService().getEncounter(encounterId);
			}
			
			// setting encounter to drug order, avoid setting encounter in case of REVISE
			if (drugOrder.getEncounter() == null)
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
			
			drugOrder.setCareSetting(Context.getOrderService().getCareSettingByName("Outpatient")); // Fetch Outpatient
			                                                                                        // care setting
			
			// setting provider
			drugOrder.setOrderer(provider);
			drugOrder.setDosingType(SimpleDosingInstructions.class);
			
			/* Note: using order_reason_non_coded for Storing "Reason for Administration", 
			because order_reason is used by discontinueOrder(...) method as reason for stopping drug */
			
			if (orderReason != null)
				drugOrder.setOrderReasonNonCoded(Context.getConceptService().getConcept(orderReason).getDescription()
				        .getDescription());
			
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
	
	public List<Concept> getDrugSets(List<String> classes) {
		List<Concept> drugSets = new ArrayList<Concept>();
		List<Concept> allSetConcepts = new ArrayList<Concept>();
		
		for (String className : classes) {
			List<Concept> setConcepts = Context.getConceptService().getConceptsByClass(
			    Context.getConceptService().getConceptClassByName(className.trim()));
			allSetConcepts.addAll(setConcepts);
		}
		
		for (Concept concept : allSetConcepts) {
			if (concept.isSet() && concept.getSetMembers().size() > 0) {
				List<Concept> setMembers = concept.getSetMembers();
				for (Concept setMember : setMembers) {
					if (setMember.getConceptClass().getName().equalsIgnoreCase("Drug") && !setMember.getRetired()
					        && Context.getConceptService().getDrugsByConcept(setMember).size() > 0) {
						if (!drugSets.contains(concept))
							drugSets.add(concept);
						break;
					}
				}
			}
		}
		
		return drugSets;
	}
	
	// can we ONLY Revise active orders? YES!
	// does the idea of changing drug related info conforms to the definition of "revise order"? No, it doesn't!
	private void reviseOrder(DrugOrder newDrugOrder, Order originalOrder, String currentUserId, Integer orderReason,
	        String orderReasonNonCoded, String adminInstructions) {
		
		Order revisedOrder = originalOrder.cloneForRevision();
		if (orderReason != null)
			revisedOrder.setOrderReasonNonCoded(Context.getConceptService().getConcept(orderReason).getDescription()
			        .getDescription());
		
		if (orderReasonNonCoded != null && !orderReasonNonCoded.isEmpty())
			revisedOrder.setOrderReasonNonCoded(orderReasonNonCoded);
		
		if (adminInstructions != null && !adminInstructions.isEmpty())
			revisedOrder.setInstructions(adminInstructions);
		
		User currentUser = Context.getUserService().getUserByUsername(currentUserId);
		org.openmrs.Provider provider = Context.getProviderService().getProvidersByPerson(currentUser.getPerson(), false)
		        .iterator().next();
		revisedOrder.setOrderer(provider);
		
		// setting the same encounter as the one associated with original order
		revisedOrder.setEncounter(originalOrder.getEncounter());
		Context.getOrderService().saveOrder(revisedOrder, null);
		
	}
	
}
