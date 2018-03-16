/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 *
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */

/**
 * @author tahira.niazi@ihsinformatics.com
 */
package org.openmrs.module.medicationlog;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Locale;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.ConceptName;
import org.openmrs.ConceptSet;
import org.openmrs.GlobalProperty;
import org.openmrs.OrderFrequency;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.ConceptService;
import org.openmrs.api.OrderService;
import org.openmrs.api.context.Context;
import org.openmrs.module.BaseModuleActivator;
import org.openmrs.util.OpenmrsConstants;

/**
 * This class contains the logic that is run every time this module is either started or shutdown
 */
public class MedicationLogActivator extends BaseModuleActivator {
	
	private Log log = LogFactory.getLog(this.getClass());
	
	public static final String MEDICATION_FREQUENCIES_CONCEPT_UUID = "medication.medicationFrequenciesConceptUuid";
	
	public static final String MEDICATION_DRUG_TYPE_CONCEPT_UUID = "medication.drugTypeUuid";
	
	public static final String MEDICATION_ORDER_REASON_CONCEPT_UUID = "medication.orderReasonUuid";
	
	public static final String MEDICATION_DRUG_SETS_PROPERTY = "medication.drugSetClasses";
	
	ConceptService conceptService;
	
	/**
	 * @see #started()
	 */
	public void started() {
		log.info("Started Medication Log");
		
		conceptService = Context.getConceptService();
		
		AdministrationService administrationService = Context.getAdministrationService();
		maybeSetGP(administrationService, OpenmrsConstants.GP_DRUG_ROUTES_CONCEPT_UUID,
		    "162394AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		maybeSetGP(administrationService, OpenmrsConstants.GP_DRUG_DOSING_UNITS_CONCEPT_UUID,
		    "162384AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		maybeSetGP(administrationService, OpenmrsConstants.GP_DRUG_DISPENSING_UNITS_CONCEPT_UUID,
		    "162402AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		maybeSetGP(administrationService, OpenmrsConstants.GP_DURATION_UNITS_CONCEPT_UUID,
		    "1732AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		maybeSetGP(administrationService, MEDICATION_FREQUENCIES_CONCEPT_UUID, "160855AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		maybeSetGP(administrationService, MEDICATION_ORDER_REASON_CONCEPT_UUID, "a351615f-1a76-49b3-9813-a078cf31cc82");
		maybeSetGP(administrationService, MEDICATION_DRUG_SETS_PROPERTY, "LabSet");
		
		ensureOrderFrequencies(Context.getOrderService(), Context.getConceptService(), Context.getAdministrationService()
		        .getGlobalPropertyObject(MEDICATION_FREQUENCIES_CONCEPT_UUID).getPropertyValue());
		
		// creating DRUG TYPE concept
		List<Concept> drugTypeMembers = new ArrayList<Concept>();
		drugTypeMembers.add(createConcept("TUBERCULOSIS DRUGS", "Misc", "N/A"));
		drugTypeMembers.add(createConcept("NON TB DRUGS", "Misc", "N/A"));
		
		Concept drugType = createConcept("DRUG TYPE", "Question", "N/A");
		
		if (!(drugType == null)) {
			addSetMembers(drugType, drugTypeMembers);
			maybeSetGP(administrationService, MEDICATION_DRUG_TYPE_CONCEPT_UUID, drugType.getUuid());
		}
		
	}
	
	private void maybeSetGP(AdministrationService service, String prop, String val) {
		GlobalProperty gp = service.getGlobalPropertyObject(prop);
		if (gp == null) {
			service.saveGlobalProperty(new GlobalProperty(prop, val));
		} else if (StringUtils.isEmpty(gp.getPropertyValue())) {
			gp.setPropertyValue(val);
			service.saveGlobalProperty(gp);
		}
	}
	
	private void ensureOrderFrequencies(OrderService orderService, ConceptService conceptService, String uuid) {
		if (orderService.getOrderFrequencies(true).size() == 0) {
			Concept set = conceptService.getConceptByUuid(uuid);
			if (set != null) {
				for (ConceptAnswer conceptAnswer : set.getAnswers()) {
					Concept concept = conceptAnswer.getAnswerConcept();
					if (concept != null) {
						OrderFrequency frequency = new OrderFrequency();
						frequency.setConcept(concept);
						orderService.saveOrderFrequency(frequency);
					}
				}
			}
		}
	}
	
	private Concept createConcept(String newConceptName, String conceptClass, String conceptDatatype) {
		
		Concept concept = new Concept();
		Concept existingConcept = conceptService.getConceptByName(newConceptName);
		if (existingConcept == null) {
			concept.setConceptClass(conceptService.getConceptClassByName(conceptClass));
			ConceptName conceptName = new ConceptName(newConceptName, Locale.US);
			concept.setFullySpecifiedName(conceptName);
			concept.setDatatype(conceptService.getConceptDatatypeByName(conceptDatatype));
			conceptService.saveConcept(concept);
		} else {
			concept = existingConcept;
		}
		
		return concept;
	}
	
	private void addSetMembers(Concept setConcept, List<Concept> conceptList) {
		
		if (!setConcept.isSet())
			setConcept.setSet(true);
		
		List<Concept> setMembers = setConcept.getSetMembers();
		
		for (Concept concept : conceptList) {
			if (!setMembers.contains(concept))
				setConcept.addSetMember(concept);
		}
	}
	
	/**
	 * @see #shutdown()
	 */
	public void shutdown() {
		log.info("Shutdown Medication Log");
	}
	
}
