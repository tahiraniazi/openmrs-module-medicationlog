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
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;

import org.openmrs.DrugOrder;
import org.openmrs.Order;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.resources.DrugOrderWrapper;
import org.openmrs.module.medicationlog.util.DateUtil;
import org.openmrs.web.controller.PortletController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
@Controller
@RequestMapping("**/completedRegimen.portlet")
public class CompletedRegimenPortletController extends PortletController {
	
	protected void populateModel(HttpServletRequest request, Map<String, Object> model) {
		
		Logger.getAnonymousLogger().info(
		    "================================================== in Completed Regimen Protlet controller");
		
		// Fetching completed/non-active drug orders
		int patientId = Integer.parseInt(request.getParameter("patientId"));
		Patient patient = Context.getPatientService().getPatient(patientId);
		List<Order> allOrders = Context.getOrderService().getAllOrdersByPatient(patient);
		
		List<DrugOrderWrapper> completedDrugOrders = new ArrayList<DrugOrderWrapper>();
		for (Order order : allOrders) {
			DrugOrder drugOrder = (DrugOrder) Context.getOrderService().getOrder(order.getId());
			
			/*			Date autoExpireDate = null;
						Date dateStopped = null;*/
			boolean isExpired = false;
			boolean isStopped = false;
			
			/*			if (drugOrder.getAutoExpireDate() != null)
							autoExpireDate = drugOrder.getAutoExpireDate();
						if (drugOrder.getDateStopped() != null)
							dateStopped = drugOrder.getDateStopped();*/
			
			if (drugOrder.getAutoExpireDate() != null
			        && DateUtil.beforeSecondDate(drugOrder.getAutoExpireDate(), new Date()))
				isExpired = true;
			
			if (drugOrder.getDateStopped() != null && DateUtil.beforeSecondDate(drugOrder.getDateStopped(), new Date()))
				isStopped = true;
			
			if (isExpired || isStopped) {
				DrugOrderWrapper drugOrderWrapper = new DrugOrderWrapper(order.getId(), drugOrder.getDrug().getDrugId(),
				        drugOrder.getDrug().getConcept().getDisplayString().toLowerCase(), drugOrder.getDose(), drugOrder
				                .getDoseUnits().getDisplayString().toLowerCase(), drugOrder.getFrequency().getConcept()
				                .getDisplayString().toLowerCase(), drugOrder.getRoute().getDisplayString().toLowerCase(),
				        drugOrder.getDuration(), drugOrder.getDurationUnits().getDisplayString().toLowerCase(),
				        drugOrder.getDateActivated());
				
				if (drugOrder.getAutoExpireDate() != null) {
					drugOrderWrapper.setScheduledDate(drugOrder.getAutoExpireDate());
				}
				
				if (drugOrder.getInstructions() != null && !drugOrder.getInstructions().isEmpty()) {
					drugOrderWrapper.setInstructions(drugOrder.getInstructions());
				}
				
				completedDrugOrders.add(drugOrderWrapper);
			}
		}
		model.put("completedDrugOrders", completedDrugOrders);
	}
}
