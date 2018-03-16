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
import java.util.Collection;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.DrugOrder;
import org.openmrs.Patient;
import org.openmrs.api.ConceptService;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.MedicationLogActivator;
import org.openmrs.web.controller.PortletController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
@Controller
@RequestMapping("**/medication.portlet")
public class MedicationPortletController extends PortletController {
	
	ConceptService conceptService = Context.getConceptService();
	
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
		Concept frequencySet = conceptService.getConceptByUuid(frequencyUuid);
		List<Concept> frequencies = frequencySet.getSetMembers();
		log.info("Frequency concepts are " + frequencies);
		model.put("frequencies", frequencies);
		
		String drugTypeUuid = Context.getAdministrationService().getGlobalProperty(
		    MedicationLogActivator.MEDICATION_DRUG_TYPE_CONCEPT_UUID);
		Concept drugTypeSet = conceptService.getConceptByUuid(drugTypeUuid);
		List<Concept> drugTypes = drugTypeSet.getSetMembers();
		log.info("Drug type concepts are " + drugTypes);
		// model.put("drugTypes", drugTypes);
		
		//		String administrationReasonUuid = Context.getAdministrationService().getGlobalProperty(
		//		    MedicationLogActivator.MEDICATION_ORDER_REASON_CONCEPT_UUID);
		//		if (administrationReasonUuid != null && !administrationReasonUuid.isEmpty()) {
		//			Concept orderReason = conceptService.getConceptByUuid(administrationReasonUuid);
		//			Collection<ConceptAnswer> reasonCollection = orderReason.getAnswers(false);
		//			ArrayList<Concept> reasons = new ArrayList<Concept>();
		//			
		//			for (ConceptAnswer reason : reasonCollection) {
		//				reasons.add(reason.getAnswerConcept());
		//				
		//			}
		//			log.info("Order reason concepts are " + reasons);
		//			model.put("orderReasons", reasons);
		//		}
		
		// reading drug set classes global property (it indicates the types of
		// concept sets required e.g LabSet, ConvSet). Get the comma-separated
		// values and fetch these concepts by class and then generate the final
		// list of the drug set concepts
		
		//		String drugClasses = Context.getAdministrationService().getGlobalProperty(
		//		    MedicationLogActivator.MEDICATION_DRUG_SETS_PROPERTY);
		//		
		//		List<String> classes = new ArrayList<String>();
		List<Concept> drugSets = new ArrayList<Concept>();
		//		
		//		// search drug sets based on drug classes specified in advance settings
		//		if (drugClasses != null && !drugClasses.isEmpty()) {
		//			classes = Arrays.asList(drugClasses.split(",").toString().trim());
		//			drugSets = getDrugSets(classes);
		//		}
		//		// else search concept sets for all Set classes like ConvSet, MedSet
		//		// etc.
		//		else {
		//			drugClasses = "LabSet, MedSet, ConvSet";
		//			classes = Arrays.asList(drugClasses.split(",").toString().trim());
		//			drugSets = getDrugSets(classes);
		//		}
		//		
		model.put("drugSets", drugSets);
	}
	
	public List<Concept> getDrugSets(List<String> classes) {
		List<Concept> drugSets = new ArrayList<Concept>();
		List<Concept> allSetConcepts = new ArrayList<Concept>();
		
		for (String className : classes) {
			List<Concept> setConcepts = conceptService.getConceptsByClass(conceptService.getConceptClassByName(className));
			allSetConcepts.addAll(setConcepts);
		}
		
		for (Concept concept : allSetConcepts) {
			if (concept.isSet() && concept.getSetMembers().size() > 0) {
				List<Concept> setMembers = concept.getSetMembers();
				for (Concept setMember : setMembers) {
					if (setMember.getConceptClass().getName().equalsIgnoreCase("Drug")) {
						if (!drugSets.contains(concept))
							drugSets.add(concept);
						break;
					}
				}
			}
		}
		
		return drugSets;
		
	}
	
	/*
	 * saves a new drug order
	 */
	@RequestMapping(value = "/addDrugOrder", method = RequestMethod.POST)
	public String addDrugOrder(ModelMap model, @RequestParam(value = "patientId", required = true) Integer patientId,
	        @RequestParam(value = "drug", required = true) Integer drugId,
	        @RequestParam(value = "dose", required = true) Double dose) {
		
		Patient patient = Context.getPatientService().getPatient(patientId);
		DrugOrder drugOrder = new DrugOrder();
		drugOrder.setPatient(patient);
		
		// save drug order
		
		return "redirect";
	}
	
}
