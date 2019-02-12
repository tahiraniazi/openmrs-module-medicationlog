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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

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
import org.openmrs.Person;
import org.openmrs.SimpleDosingInstructions;
import org.openmrs.User;
import org.openmrs.Order.Action;
import org.openmrs.api.APIException;
import org.openmrs.api.ConceptService;
import org.openmrs.api.OrderContext;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.MedicationLogActivator;
import org.openmrs.module.medicationlog.resources.DrugOrderWrapper;
import org.openmrs.module.medicationlog.util.ExclusionStrategyUtil;
import org.openmrs.web.WebConstants;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * @author tahira.niazi@ihsinformatics.com
 */

@Controller
@RequestMapping(value = "module/medicationlog/multiDrugOrder")
public class MultiDrugOrderController {
	
	public static final String SQL_DATE = "yyyy-MM-dd";
	
	public static final String DATE_FORMAT = "dd/MM/yyyy";
	
	SimpleDateFormat sdf = new SimpleDateFormat(SQL_DATE);
	
	SimpleDateFormat sdfDate = new SimpleDateFormat(DATE_FORMAT);
	
	SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
	
	protected final Log log = LogFactory.getLog(getClass());
	
	@RequestMapping(method = RequestMethod.GET)
	public void showMultiDrugOrderForm(HttpServletRequest request, Map<String, Object> model) {
		
		// not using order.durationUnitsConceptUuid but rather newly created medication.durationUnitsUuid because it has limited options that we need
		String durationUnitsUuid = Context.getAdministrationService().getGlobalProperty("medication.durationUnitsUuid");
		if (durationUnitsUuid != null && !durationUnitsUuid.isEmpty()) {
			Concept durationUnitConcept = Context.getConceptService().getConceptByUuid(durationUnitsUuid);
			if (durationUnitConcept != null && durationUnitConcept.getAnswers(false).size() > 0) {
				Collection<ConceptAnswer> durationUnitCollection = durationUnitConcept.getAnswers(false);
				ArrayList<Concept> durationUnits = new ArrayList<Concept>();
				
				for (ConceptAnswer unit : durationUnitCollection) {
					durationUnits.add(unit.getAnswerConcept());
					
				}
				model.put("durationUnits", durationUnits);
			}
		}
		
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
		
		if (orderReasonUuid != null && !orderReasonUuid.isEmpty()) {
			Concept orderReason = Context.getConceptService().getConceptByUuid(orderReasonUuid);
			if (orderReason != null && orderReason.getAnswers(false).size() > 0) {
				Collection<ConceptAnswer> reasonCollection = orderReason.getAnswers(false);
				ArrayList<Concept> reasons = new ArrayList<Concept>();
				
				for (ConceptAnswer reason : reasonCollection) {
					reasons.add(reason.getAnswerConcept());
					
				}
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
	@RequestMapping(value = "/addMultipleDrugOrders.form", method = RequestMethod.POST)
	@ResponseBody
	public String addMultipleDrugOrders(ModelMap model, HttpSession httpSession, HttpServletRequest request,
	        @RequestBody String ordersJson, @RequestParam(required = false) Integer patientId) {
		
		String returnPage = "/patientDashboard.form?patientId=" + patientId;
		try {
			JsonArray orderArray = (JsonArray) new JsonParser().parse(ordersJson);
			
			for (int i = 0; i < orderArray.size(); i++) {
				JsonObject jsonObject = orderArray.get(i).getAsJsonObject();
				String drugSelection = jsonObject.get("drugSelection").getAsString();
				String drugName = jsonObject.get("drugName").getAsString();
				Integer drugId = jsonObject.get("drugId").getAsInt();
				Double dose = jsonObject.get("dose").getAsDouble();
				Integer doseUnit = jsonObject.get("doseUnit").getAsInt();
				Integer frequency = jsonObject.get("frequency").getAsInt();
				Integer route = jsonObject.get("route").getAsInt();
				int duration = jsonObject.get("duration").getAsInt();
				Integer durationUnit = jsonObject.get("durationUnit").getAsInt();
				String dosingInstruction = jsonObject.get("instruction").getAsString();
				String startDateDrug = jsonObject.get("startDrugDate").getAsString();
				Integer patient = jsonObject.get("patientId").getAsInt();
				Integer encounterId = jsonObject.get("encounterId").getAsInt();
				String currentUserId = jsonObject.get("userId").getAsString();
				
				Date startDateOrder = sdfDate.parse(startDateDrug);
				
				DrugOrder drugOrder = constructDrugOrderObject(null, currentUserId, patientId, drugId, drugName,
				    drugSelection, encounterId, dose, doseUnit, frequency, route, dosingInstruction, startDateOrder,
				    duration, durationUnit, null, null, null, null);
				
				OrderContext orderContext = new OrderContext();
				Context.getOrderService().saveOrder(drugOrder, orderContext);
				
			}
		}
		catch (Exception e) {
			e.printStackTrace();
			String error = "FAIL: Unable to create Drug Order. \n";
			if (e.getMessage().equals("Order.cannot.have.more.than.one"))
				error += "Cannot have more than one active order for the same orderable and care setting at same time.";
			else
				error += e.getMessage();
			
			model.addAttribute("error", error);
			model.addAttribute("patientId", patientId);
			
			return error;
			
		}
		
		// save alert
		request.getSession().setAttribute(WebConstants.OPENMRS_MSG_ATTR, "medication.drugOrder.saved");
		Logger.getAnonymousLogger().info(returnPage);
		// return "redirect";
		return "SUCCESS: Drug orders saved successfully.";
	}
	
	private DrugOrder constructDrugOrderObject(DrugOrder drugOrder, String currentUserid, Integer patientId, Integer drugId,
	        String drugName, String drugSelection, Integer encounterId, Double dose, Integer doseUnit, Integer frequency,
	        Integer route, String dosingInstructions, Date startDateDrug, int duration, Integer durationUnit,
	        String asNeeded, Integer orderReason, String orderReasonOther, String adminInstructions) {
		
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
			
			// Add current time to start date
			String startDate = new SimpleDateFormat(SQL_DATE).format(startDateDrug);
			String time = timeFormat.format(new Date());
			
			LocalDate datePart = LocalDate.parse(startDate);
			LocalTime timePart = LocalTime.parse(time);
			LocalDateTime startingDate = LocalDateTime.of(datePart, timePart);
			
			Logger.getAnonymousLogger().info(
			    "LocalDateTime: Starting date >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + startingDate);
			startDateDrug = convertToDateViaSqlTimestamp(startingDate);
			Logger.getAnonymousLogger().info(
			    "Java Date: Starting date >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + startDateDrug);
			
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
			
			if (orderReason != null) {
				drugOrder.setOrderReasonNonCoded(Context.getConceptService().getConcept(orderReason).getDescription()
				        .getDescription());
			} else if (orderReasonOther != null && !orderReasonOther.isEmpty()) {
				drugOrder.setOrderReasonNonCoded(orderReasonOther);
			}
			
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
	
	public Date convertToDateViaSqlTimestamp(LocalDateTime dateToConvert) {
		return java.sql.Timestamp.valueOf(dateToConvert);
	}
	
}
