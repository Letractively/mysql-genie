package genie;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;

/**
 * Singleton object for managing List object caching
 * 
 * @author Spencerh
 *
 */
public class ListCache {

//	static ListCache instance = null;
	static String urlString = null;	
	Hashtable<String, List<String>> lists = new Hashtable<String, List<String>>();
			
	private ListCache() {
	}
	
	public static ListCache getInstance() {
/*		if (instance==null && urlString==null) {
			urlString = urlStr;
			instance = new ListCache();
		}*/
		ListCache instance =  new ListCache();
		return instance;
	}
	
	public List<String> getListObject(String sql) {
		List<String> list = lists.get(sql);
		return list;
	}
	
	public void addList(String sql, List<String> list) {
		lists.put(sql, list);
	}
	
	public void removeList(String sql) {
		lists.remove(sql);
	}
	
	public void clearAll() {
		lists.clear();
	}
	
	public Enumeration<String> getKeys() {
		return lists.keys();
	}		
	
}
