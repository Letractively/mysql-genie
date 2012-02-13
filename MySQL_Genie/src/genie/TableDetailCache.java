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
public class TableDetailCache {

	static TableDetailCache instance = null;
	Hashtable<String, List<TableCol>> lists = new Hashtable<String, List<TableCol>>();
			
	private TableDetailCache() {
	}
	
	public static TableDetailCache getInstance() {
		if (instance==null) {
			instance = new TableDetailCache();
		}
		return instance;
	}
	
	public List<TableCol> get(String owner, String tname) {
		if (owner != null && owner.length()>0)
			tname = owner + "." + tname;
		List<TableCol> list = lists.get(tname);
		return list;
	}
	
	public void add(String owner, String tname, List<TableCol> list) {
		if (owner != null && owner.length()>0)
			tname = owner + "." + tname;

		lists.put(tname, list);
	}
	
	public void remove(String owner, String tname) {
		if (owner != null && owner.length()>0)
			tname = owner + "." + tname;

		lists.remove(tname);
	}
	
	public void clearAll() {
		lists.clear();
	}

	public Enumeration<String> getKeys() {
		return lists.keys();
	}

}
