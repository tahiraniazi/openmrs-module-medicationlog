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

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
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
	
	public static final String MEDICATION_REASON_ORDER_STOPPED_UUID = "medication.reasonOrderStoppedUuid";
	
	ConceptService conceptService;
	
	/**
	 * @see #started()
	 */
	public void started() {
		log.info("Started Medication Log");
		
		conceptService = Context.getConceptService();
		
		AdministrationService administrationService = Context.getAdministrationService();
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DRUG_ROUTES_CONCEPT_UUID,
		    "162394AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DRUG_DOSING_UNITS_CONCEPT_UUID,
		    "162384AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DRUG_DISPENSING_UNITS_CONCEPT_UUID,
		    "162402AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DURATION_UNITS_CONCEPT_UUID,
		    "1732AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, MEDICATION_FREQUENCIES_CONCEPT_UUID, "160855AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, MEDICATION_ORDER_REASON_CONCEPT_UUID,
		    "a351615f-1a76-49b3-9813-a078cf31cc82");
		
		setGlobalProperty(administrationService, MEDICATION_REASON_ORDER_STOPPED_UUID,
		    "25426941-0fe6-4e0c-adc9-b396416606f5");
		setGlobalProperty(administrationService, MEDICATION_DRUG_SETS_PROPERTY, "LabSet");
		
		ensureOrderFrequencies(Context.getOrderService(), Context.getConceptService(), Context.getAdministrationService()
		        .getGlobalPropertyObject(MEDICATION_FREQUENCIES_CONCEPT_UUID).getPropertyValue());
		
		setGlobalProperty(administrationService, MEDICATION_DRUG_TYPE_CONCEPT_UUID, "43029b8a-cbed-4085-a650-44f209d683d3");
		
	}
	
	private void setGlobalProperty(AdministrationService service, String prop, String val) {
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
	
	/**
	 * @see #shutdown()
	 */
	public void shutdown() {
		log.info("Shutdown Medication Log");
	}
	
	/**
	 * Called for each module after spring's application context is refreshed , this method is also
	 * called multiple times i.e. whenever a new module gets started and at application startup.
	 */
	public void contextRefreshed() {
		
		log.info("========================================================= Medication Log contextRefreshed called");
		
		conceptService = Context.getConceptService();
		
		AdministrationService administrationService = Context.getAdministrationService();
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DRUG_ROUTES_CONCEPT_UUID,
		    "162394AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DRUG_DOSING_UNITS_CONCEPT_UUID,
		    "162384AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DRUG_DISPENSING_UNITS_CONCEPT_UUID,
		    "162402AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, OpenmrsConstants.GP_DURATION_UNITS_CONCEPT_UUID,
		    "1732AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, MEDICATION_FREQUENCIES_CONCEPT_UUID, "160855AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		setGlobalProperty(administrationService, MEDICATION_ORDER_REASON_CONCEPT_UUID,
		    "a351615f-1a76-49b3-9813-a078cf31cc82");
		
		setGlobalProperty(administrationService, MEDICATION_REASON_ORDER_STOPPED_UUID,
		    "25426941-0fe6-4e0c-adc9-b396416606f5");
		setGlobalProperty(administrationService, MEDICATION_DRUG_SETS_PROPERTY, "LabSet");
		
		ensureOrderFrequencies(Context.getOrderService(), Context.getConceptService(), Context.getAdministrationService()
		        .getGlobalPropertyObject(MEDICATION_FREQUENCIES_CONCEPT_UUID).getPropertyValue());
		
		setGlobalProperty(administrationService, MEDICATION_DRUG_TYPE_CONCEPT_UUID, "43029b8a-cbed-4085-a650-44f209d683d3");
		
	}
	
}
