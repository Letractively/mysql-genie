package genie;

import java.util.ArrayList;

public class GenieManager {

	private static GenieManager instance = null;
	ArrayList<Connect> sessions = new ArrayList<Connect>();
	
	private GenieManager() {
		
	}
	
	public static GenieManager getInstance() {
		if (instance==null) {
			instance = new GenieManager();
		}
		return instance;
	}
	
	public void addSession(Connect cn) {
		sessions.add(cn);
	}
	
	public void removeSession(Connect cn) {
		sessions.remove(cn);
	}
	
	public ArrayList<Connect> getSessions() {
		return sessions;
	}
}
