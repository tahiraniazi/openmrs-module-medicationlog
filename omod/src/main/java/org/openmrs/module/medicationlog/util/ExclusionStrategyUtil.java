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
package org.openmrs.module.medicationlog.util;

import org.openmrs.Encounter;
import org.openmrs.User;
import org.openmrs.module.medicationlog.resources.DrugOrderWrapper;

import com.google.gson.ExclusionStrategy;
import com.google.gson.FieldAttributes;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
public class ExclusionStrategyUtil implements ExclusionStrategy {
	
	/* (non-Javadoc)
	 * @see com.google.gson.ExclusionStrategy#shouldSkipClass(java.lang.Class)
	 */
	@Override
	public boolean shouldSkipClass(Class<?> c) {
		// TODO Auto-generated method stub
		return (c.equals(User.class));
	}
	
	/* (non-Javadoc)
	 * @see com.google.gson.ExclusionStrategy#shouldSkipField(com.google.gson.FieldAttributes)
	 */
	@Override
	public boolean shouldSkipField(FieldAttributes f) {
		
		return (f.getName().equals("orderEncounter"));
	}
	
}
