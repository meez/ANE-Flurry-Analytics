package com.sticksports.nativeExtensions.flurry;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAgent;

import java.lang.reflect.Constructor;

public class FlurryInitFunction implements FREFunction
{

	@Override
	public FREObject call( FREContext context, FREObject[] args )
	{
		try
		{
			String id = args[0].getAsString();
            FlurryAgent.init( context.getActivity(), id );
		}
		catch ( Throwable t )
		{
			Log.w( "Flurry", t );
		}
		return null;
	}
}