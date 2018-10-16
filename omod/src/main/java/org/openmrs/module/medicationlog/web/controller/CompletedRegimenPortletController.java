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
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;

import org.openmrs.DrugOrder;
import org.openmrs.Order;
import org.openmrs.OrderType;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.medicationlog.resources.DrugOrderWrapper;
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
		
		SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
		String time = timeFormat.format(new Date());
		Logger.getAnonymousLogger().info("Time part >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + time);
		
		// Fetching completed/non-active drug orders
		int patientId = Integer.parseInt(request.getParameter("patientId"));
		Patient patient = Context.getPatientService().getPatient(patientId);
		List<Order> allOrders = Context.getOrderService().getAllOrdersByPatient(patient);
		
		List<DrugOrderWrapper> completedDrugOrders = new ArrayList<DrugOrderWrapper>();
		for (Order order : allOrders) {
			
			// TODO: test this part
			if (order instanceof DrugOrder) {
				
				DrugOrder drugOrder = null;
				Order discontinuedOrder = null;
				
				boolean isExpired = false;
				boolean isStopped = false;
				if (order.getAutoExpireDate() != null && (order.getAutoExpireDate().compareTo(new Date()) < 0)) // before second date
					isExpired = true;
				if (order.getDateStopped() != null && (order.getDateStopped().compareTo(new Date()) < 0)) // before second date
					isStopped = true;
				
				if (isExpired || isStopped) {
					
					//	Fetching the discontinued order for this order
					if (order.getAction() == Order.Action.DISCONTINUE) {
						
						discontinuedOrder = Context.getOrderService().getOrder(order.getId());
						order = discontinuedOrder.getPreviousOrder();
						drugOrder = (DrugOrder) order;
					} else {
						drugOrder = (DrugOrder) order;
					}
					
					DrugOrderWrapper drugOrderWrapper = new DrugOrderWrapper(order.getOrderId(), order.getEncounter()
					        .getEncounterType().getName(), order.getEncounter(), order.getDateCreated(), order.getOrderer()
					        .getCreator().getUsername(), order.getUuid(), drugOrder.getDrug().getDrugId(), drugOrder
					        .getDrug().getConcept().getDisplayString().toLowerCase(), drugOrder.getDose(), drugOrder
					        .getDoseUnits().getDisplayString().toLowerCase(), drugOrder.getFrequency().getConcept()
					        .getDisplayString().toLowerCase(), drugOrder.getRoute().getDisplayString().toLowerCase(),
					        drugOrder.getDuration(), drugOrder.getDurationUnits().getDisplayString().toLowerCase(),
					        order.getDateActivated());
					
					if (drugOrder.getDateStopped() == null) {
						if (drugOrder.getAutoExpireDate() != null)
							drugOrderWrapper.setScheduledStopDate(drugOrder.getAutoExpireDate());
					} else {
						drugOrderWrapper.setDateStopped(drugOrder.getDateStopped());
						drugOrderWrapper.setScheduledStopDate(drugOrder.getDateStopped());
					}
					
					if (drugOrder.getInstructions() != null && !drugOrder.getInstructions().isEmpty())
						drugOrderWrapper.setInstructions(drugOrder.getInstructions());
					
					if (discontinuedOrder != null
					        && (discontinuedOrder.getOrderReason().getDisplayString() != null && !discontinuedOrder
					                .getOrderReason().getDisplayString().isEmpty())) {
						drugOrderWrapper.setDiscontinueReason(drugOrder.getInstructions());
					}
					
					if (!containsOrder(completedDrugOrders, order.getOrderId()))
						completedDrugOrders.add(drugOrderWrapper);
				}
			}
		}
		model.put("completedDrugOrders", completedDrugOrders);
	}
	
	public static boolean containsOrder(List<DrugOrderWrapper> list, int id) {
		for (DrugOrderWrapper order : list) {
			if (order.getOrderId() == id) {
				return true;
			}
		}
		return false;
	}
}
