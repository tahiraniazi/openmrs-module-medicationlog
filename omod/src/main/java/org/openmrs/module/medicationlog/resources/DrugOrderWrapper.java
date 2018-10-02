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
package org.openmrs.module.medicationlog.resources;

import java.util.Date;

import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.OrderFrequency;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
public class DrugOrderWrapper {
	
	// order details
	private int orderId;
	
	private Encounter orderEncounter;
	
	private String orderReason;
	
	private Date dateCreated;
	
	private String orderer;
	
	private String orderUuid;
	
	// drug order details
	private int drugId;
	
	private String drugName;
	
	private boolean asNeeded;
	
	private double dose;
	
	private String doseUnit;
	
	private String frequency;
	
	private String route;
	
	private int duration;
	
	private String durationUnit;
	
	private String instructions;
	
	private Date dateActivated;
	
	private Date dateStopped;
	
	private Date scheduledStopDate;
	
	private Date autoExpireDate;
	
	public DrugOrderWrapper() {
		
	}
	
	public DrugOrderWrapper(int orderId, Encounter orderEncounter, Date dateCreated, String orderer, String uuid,
	    int drugId, String drugName, double dose, String doseunit, String frequency, String route, int duration,
	    String durationUnit, Date dateActivated) {
		
		this.orderId = orderId;
		this.orderEncounter = orderEncounter;
		this.dateCreated = dateCreated;
		this.orderer = orderer;
		this.orderUuid = uuid;
		this.drugId = drugId;
		this.drugName = drugName;
		this.dose = dose;
		this.doseUnit = doseunit;
		this.frequency = frequency;
		this.route = route;
		this.duration = duration;
		this.durationUnit = durationUnit;
		this.dateActivated = dateActivated;
	}
	
	public DrugOrderWrapper(int orderId, int drugId, String drugName, double dose, String doseUnit, String frequency,
	    String route, int duration, String durationUnit, String instructions, Date dateActivated, Date dateStopped,
	    Date scheduledDate, Date autoExpireDate) {
		
		this.orderId = orderId;
		this.drugId = drugId;
		this.drugName = drugName;
		this.dose = dose;
		this.doseUnit = doseUnit;
		this.frequency = frequency;
		this.route = route;
		this.duration = duration;
		this.durationUnit = durationUnit;
		this.instructions = instructions;
		this.dateActivated = dateActivated;
		this.dateStopped = dateStopped;
		this.scheduledStopDate = scheduledDate;
		this.autoExpireDate = autoExpireDate;
	}
	
	public DrugOrderWrapper(int orderId, Encounter orderEncounter, String orderReason, Date dateCreated, String orderer,
	    String uuid, int drugId, String drugName, boolean asNeeded, double dose, String doseUnit, String frequency,
	    String route, int duration, String durationUnit, String instructions, Date dateActivated, Date dateStopped,
	    Date scheduledDate, Date autoExpireDate) {
		
		this.orderId = orderId;
		this.orderEncounter = orderEncounter;
		this.orderReason = orderReason;
		this.dateCreated = dateCreated;
		this.orderer = orderer;
		this.orderUuid = uuid;
		this.drugId = drugId;
		this.drugName = drugName;
		this.asNeeded = asNeeded;
		this.dose = dose;
		this.doseUnit = doseUnit;
		this.frequency = frequency;
		this.route = route;
		this.duration = duration;
		this.durationUnit = durationUnit;
		this.instructions = instructions;
		this.dateActivated = dateActivated;
		this.dateStopped = dateStopped;
		this.scheduledStopDate = scheduledDate;
		this.autoExpireDate = autoExpireDate;
	}
	
	public int getOrderId() {
		return orderId;
	}
	
	public void setOrderId(int orderId) {
		this.orderId = orderId;
	}
	
	public Encounter getOrderEncounter() {
		return orderEncounter;
	}
	
	public void setOrderEncounter(Encounter orderEncounter) {
		this.orderEncounter = orderEncounter;
	}
	
	public String getOrderReason() {
		return orderReason;
	}
	
	public void setOrderReason(String orderReason) {
		this.orderReason = orderReason;
	}
	
	public Date getDateCreated() {
		return dateCreated;
	}
	
	public void setDateCreated(Date dateCreated) {
		this.dateCreated = dateCreated;
	}
	
	public String getCreator() {
		return orderer;
	}
	
	public void setCreator(String creator) {
		this.orderer = creator;
	}
	
	public String getOrderUuid() {
		return orderUuid;
	}
	
	public void setOrderUuid(String orderUuid) {
		this.orderUuid = orderUuid;
	}
	
	public int getDrugId() {
		return drugId;
	}
	
	public void setDrugId(int drugId) {
		this.drugId = drugId;
	}
	
	public String getDrugName() {
		return drugName;
	}
	
	public void setDrugName(String drugName) {
		this.drugName = drugName;
	}
	
	public boolean isAsNeeded() {
		return asNeeded;
	}
	
	public void setAsNeeded(boolean asNeeded) {
		this.asNeeded = asNeeded;
	}
	
	public double getDose() {
		return dose;
	}
	
	public void setDose(double dose) {
		this.dose = dose;
	}
	
	public String getDoseUnit() {
		return doseUnit;
	}
	
	public void setDoseUnit(String doseUnit) {
		this.doseUnit = doseUnit;
	}
	
	public String getFrequency() {
		return frequency;
	}
	
	public void setFrequency(String frequency) {
		this.frequency = frequency;
	}
	
	public String getRoute() {
		return route;
	}
	
	public void setRoute(String route) {
		this.route = route;
	}
	
	public int getDuration() {
		return duration;
	}
	
	public void setDuration(int duration) {
		this.duration = duration;
	}
	
	public String getDurationUnit() {
		return durationUnit;
	}
	
	public void setDurationUnit(String durationUnit) {
		this.durationUnit = durationUnit;
	}
	
	public String getInstructions() {
		return instructions;
	}
	
	public void setInstructions(String instructions) {
		this.instructions = instructions;
	}
	
	public Date getDateActivated() {
		return dateActivated;
	}
	
	public void setDateActivated(Date dateActivated) {
		this.dateActivated = dateActivated;
	}
	
	public Date getDateStopped() {
		return dateStopped;
	}
	
	public void setDateStopped(Date dateStopped) {
		this.dateStopped = dateStopped;
	}
	
	public Date getScheduledStopDate() {
		return scheduledStopDate;
	}
	
	public void setScheduledStopDate(Date scheduledDate) {
		this.scheduledStopDate = scheduledDate;
	}
	
	public Date getAutoExpireDate() {
		return autoExpireDate;
	}
	
	public void setAutoExpireDate(Date autoExpireDate) {
		this.autoExpireDate = autoExpireDate;
	}
	
}
