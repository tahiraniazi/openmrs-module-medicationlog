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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Concept;
import org.openmrs.Drug;
import org.openmrs.DrugOrder;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Order;
import org.openmrs.OrderFrequency;
import org.openmrs.Patient;
import org.openmrs.Provider;
import org.openmrs.SimpleDosingInstructions;
import org.openmrs.User;
import org.openmrs.api.APIException;
import org.openmrs.api.ConceptService;
import org.openmrs.api.OrderContext;
import org.openmrs.api.context.Context;
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
@RequestMapping(value = "/module/medicationlog/order/")
public class MedicationOrderController {
	
	private static final Log log = LogFactory.getLog(MedicationPortletController.class);
	
	@RequestMapping(value = "stopDrugOrder.form", method = RequestMethod.POST)
	public String stopOrder(ModelMap model, HttpServletRequest request,
	        @RequestParam(value = "stopOrderId", required = true) Integer orderId,
	        @RequestParam(value = "orderStopReason", required = true) Integer stopReasonId,
	        @RequestParam(value = "drugStopDate", required = true) Date drugStopDate,
	        @RequestParam(value = "returnPage", required = true) String returnPage) {
		
		try {
			Order orderToDiscontinue = Context.getOrderService().getOrder(orderId);
			Encounter encounter = orderToDiscontinue.getEncounter();
			Concept reasonCoded = Context.getConceptService().getConcept(stopReasonId);
			
			Provider orderer = Context.getProviderService()
			        .getProvidersByPerson(Context.getAuthenticatedUser().getPerson(), false).iterator().next();
			
			Context.getOrderService().discontinueOrder(orderToDiscontinue, reasonCoded, drugStopDate, orderer, encounter);
			
			String stopped_status = "medication.drugOrder.stopped";
			//model.addAttribute("stopped_status", stopped_status);
			
		}
		catch (APIException e) {
			e.printStackTrace();
			
			String error = "An error occured! Could not stop drug order.";
			model.addAttribute("error", error);
		}
		
		request.getSession().setAttribute(WebConstants.OPENMRS_MSG_ATTR, "medication.drugOrder.stopped");
		return "redirect:" + returnPage;
		
	}
}
