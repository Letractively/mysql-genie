package genie;

import java.util.Date;

public class QueryLog {
	Date qryTime = new Date();	
	String qryString;
	
	public QueryLog(String q) {
		qryString = q;
	}
	
	public String getQueryString() {
		return qryString;
	}
	
	public Date getTime() {
		return qryTime;
	}
}
