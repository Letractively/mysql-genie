package genie;

import java.util.Enumeration;
import java.util.Hashtable;

/**
 * Singleton object for managing Query object caching
 * 
 * @author Spencerh
 *
 */
public class QueryCache {

//	static QueryCache instance = null;
	static String urlString = null;
	Hashtable<String, Query> qrys = new Hashtable<String, Query>();
			
	private QueryCache() {
	}
	
	public static QueryCache getInstance() {
/*		if (instance==null && urlString==null) {
			urlString = urlStr;
			instance = new QueryCache();
		}
*/		QueryCache instance = new QueryCache();
		return instance;
	}
	
	public Query getQueryObject(String sql) {
		Query qry = qrys.get(sql);
		return qry;
	}
	
	public void addQuery(String sql, Query qry) {
		qrys.put(sql, qry);
	}
	
	public void removeQuery(String sql) {
		qrys.remove(sql);
	}
	
	public void clearAll() {
		qrys.clear();
	}

	public Enumeration<String> getKeys() {
		return qrys.keys();
	}	
}
