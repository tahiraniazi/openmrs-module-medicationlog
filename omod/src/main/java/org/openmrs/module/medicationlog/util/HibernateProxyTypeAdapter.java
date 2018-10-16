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

import java.io.IOException;

import org.hibernate.Hibernate;
import org.hibernate.proxy.HibernateProxy;

import com.google.gson.Gson;
import com.google.gson.TypeAdapter;
import com.google.gson.TypeAdapterFactory;
import com.google.gson.reflect.TypeToken;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;

/**
 * @author tahira.niazi@ihsinformatics.com
 */
public class HibernateProxyTypeAdapter extends TypeAdapter<HibernateProxy> {
	
	public static final TypeAdapterFactory FACTORY = new TypeAdapterFactory() {
		
		@Override
		@SuppressWarnings("unchecked")
		public <T> TypeAdapter<T> create(Gson gson, TypeToken<T> type) {
			return (HibernateProxy.class.isAssignableFrom(type.getRawType()) ? (TypeAdapter<T>) new HibernateProxyTypeAdapter(
			        gson) : null);
		}
	};
	
	private final Gson context;
	
	private HibernateProxyTypeAdapter(Gson context) {
		this.context = context;
	}
	
	/* (non-Javadoc)
	 * @see com.google.gson.TypeAdapter#read(com.google.gson.stream.JsonReader)
	 */
	@Override
	public HibernateProxy read(JsonReader in) throws IOException {
		throw new UnsupportedOperationException("Not supported");
	}
	
	/* (non-Javadoc)
	 * @see com.google.gson.TypeAdapter#write(com.google.gson.stream.JsonWriter, java.lang.Object)
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public void write(JsonWriter out, HibernateProxy value) throws IOException {
		if (value == null) {
			out.nullValue();
			return;
		}
		// Retrieve the original (not proxy) class
		Class<?> baseType = Hibernate.getClass(value);
		// Get the TypeAdapter of the original class, to delegate the serialization
		TypeAdapter delegate = context.getAdapter(TypeToken.get(baseType));
		// Get a filled instance of the original class
		Object unproxiedValue = ((HibernateProxy) value).getHibernateLazyInitializer().getImplementation();
		// Serialize the value
		delegate.write(out, unproxiedValue);
		
	}
	
}
