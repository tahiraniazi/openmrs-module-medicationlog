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
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.Encounter;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.MedicationLogActivator;
import org.openmrs.web.controller.PortletController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
@Controller
@RequestMapping("**/medication.portlet")
public class MedicationPortletController extends PortletController {
	
	private static final Log log = LogFactory.getLog(MedicationPortletController.class);
	
	protected void populateModel(HttpServletRequest request, Map<String, Object> model) {
		
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
		Logger.getAnonymousLogger().info("=============================== patient id :" + patientId);
		
		Patient patient = Context.getPatientService().getPatient(patientId);
		// encounters in ASC order by encounter date time
		List<Encounter> allEncounters = Context.getEncounterService().getEncountersByPatient(patient);
		
		// reversing the list to get encounters in DESC order by encounter date time
		List<Encounter> descEncounters = allEncounters.subList(0, allEncounters.size());
		Collections.reverse(descEncounters);
		
		if (descEncounters.size() > 3)
			descEncounters = new ArrayList<Encounter>(descEncounters.subList(0, 3));
		
		List<Map<String, String>> encounters = new ArrayList<Map<String, String>>();
		for (Encounter encounter : descEncounters) {
			Map<String, String> encounterInfo = new HashMap<String, String>();
			encounterInfo.put("encounterId", Integer.toString(encounter.getEncounterId()));
			encounterInfo.put("encounterName", encounter.getEncounterType().getName());
			encounters.add(encounterInfo);
		}
		
		model.put("encounters", encounters);
		//*
		
		// put order sets in model
		
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
}
