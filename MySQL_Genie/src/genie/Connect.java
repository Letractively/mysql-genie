package genie;

/**
 * Connection class
 * 
 * This is the Singlton class for login user
 * It will maintain database connection and provide database access methods
 * 
 * @author spencer.hwang
 * 
 */

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;

public class Connect implements HttpSessionBindingListener {

	private Connection conn = null;
	private String urlString = null;
	private String message = "";
	private List<String> tables;

	private HashSet<String> comment_tables = new HashSet<String>();
	private Hashtable<String,String> comments;
	private Hashtable<String,String> constraints;
	private Hashtable<String,String> pkByTab;
	private Hashtable<String,String> pkByCon;
	private List<ForeignKey> foreignKeys;

	private List<String> schemas;
	private String schemaName;
	private String ipAddress;
	//private Hashtable<String, String> pkColumn;
	private HashMap<String, String> queryResult;
	private HashMap<String, QueryLog> queryLog;
	private HashMap<String, ArrayList<String>> pkMap;
	private Stack<String> history;

	public QueryCache queryCache;
	public ListCache listCache;
	public ListCache2 listCache2;
	public StringCache stringCache;
	public TableDetailCache tableDetailCache; 
	public ContentSearch contentSearch;
	
	/**
	 * Constructor
	 * 
	 * @param url jdbc url
	 * @param userName	database user name
	 * @param password	database password
	 * @param ipAddress	user's local ip address
	 */
    public Connect(String url, String userName, String password, String ipAddress, boolean loadData)
    {
    	//pkColumn = new Hashtable<String, String>();
    	queryResult = new HashMap<String, String>();
    	pkMap = new HashMap<String, ArrayList<String>>();
    	
    	history = new Stack<String>();
    	
    	this.ipAddress = ipAddress;
        try
        {
            Class.forName ("com.mysql.jdbc.Driver").newInstance ();
            conn = DriverManager.getConnection (url, userName, password);
            conn.setReadOnly(true);
            
            urlString = userName + "@" + url;  
            System.out.println ("Database connection established for " + urlString + " @" + (new Date()) + " " + ipAddress);
           
            if (!loadData) return; 
            	
            tables = new Vector<String>();
            comments = new Hashtable<String, String>();
            constraints = new Hashtable<String, String>();
            pkByTab = new Hashtable<String, String>();
            pkByCon = new Hashtable<String, String>();
            
            foreignKeys = new ArrayList<ForeignKey>();
            schemas = new Vector<String>();
            queryLog = new HashMap<String, QueryLog>();

       		this.schemaName = conn.getCatalog();
//       		this.schemaName = userName;
//       		System.out.println("this.schemaName=" + this.schemaName);

            queryCache = QueryCache.getInstance(urlString);
            listCache = ListCache.getInstance(urlString);
            listCache2 = ListCache2.getInstance(urlString);
            stringCache = StringCache.getInstance(urlString);
            tableDetailCache = TableDetailCache.getInstance(urlString);
            contentSearch = ContentSearch.getInstance(urlString);
       		
            loadData();
        }
        catch (Exception e)
        {
            System.err.println ("Cannot connect to database server");
            message = e.getMessage();
        }
    }
    
    public Connect(String url, String userName, String password, String ipAddress) {
    	this(url, userName, password, ipAddress, true);
	}    
    
    /**
     * 
     * @return true if connected to database, false otherwise 
     */
    public boolean isConnected() {
    	return conn != null;
    }
    
    /**
     * close the connection
     */
    public void disconnect() {
    	if (conn != null)	{
    		try {
                conn.close ();
                System.out.println ("Database connection terminated for " + urlString + " @" + (new Date()) + " " + ipAddress);
            }
            	catch (Exception e) { /* ignore close errors */ }
        }
    	
    	conn = null;
    }
    
    /**
     * get message
     * @return String message
     */
    public String getMessage() {
    	return message;
    }
    
    /** 
     * get Connection object
     * @return connection object
     */
    public Connection getConnection() {
    	return conn;
    }
    
    public List<String> getTables() {
    	return this.tables;
    }

    public String getTable(int idx) {
    	return (String) tables.get(idx);
    }
    
    public String getUrlString() {
    	return urlString;
    }

    public String getSchemaName() {
    	return this.schemaName;
    }
    
    public List<String> getSchemas() {
    	return this.schemas;
    }
    
    public String getSchema(int idx) {
    	return (String) schemas.get(idx);
    }
    
//    public void getTableDetail(String table) throws SQLException {
//    	DatabaseMetaData dbm = conn.getMetaData();
//        ResultSet rs1 = dbm.getColumns(null,"%",table,"%");
//        while (rs1.next()){
//        	String col_name = rs1.getString("COLUMN_NAME");
//        	String data_type = rs1.getString("TYPE_NAME");
//        	int data_size = rs1.getInt("COLUMN_SIZE");
//        	int nullable = rs1.getInt("NULLABLE");
///*        	
//        	System.out.print(col_name+"\t"+data_type+"("+data_size+")"+"\t");
//        	if(nullable == 1){
//        		System.out.print("YES\t");
//        	}
//        	else{
//        		System.out.print("NO\t");
//        	}
//        	System.out.println();
//*/        	
//        }
//	}

    public void printQueryLog() {
    	HashMap<String, QueryLog> map = this.getQueryHistory();

    	if (map == null) return;
        
    	Iterator iterator = map.values().iterator();
    	int idx = 0;
    	while  (iterator.hasNext()) {
    		idx ++;
    		QueryLog ql = (QueryLog) iterator.next();
    		System.out.println(ql.getQueryString());
    	}
    	System.out.println("***] Query History from " + this.ipAddress);
    }
    
	public void valueBound(HttpSessionBindingEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	public void valueUnbound(HttpSessionBindingEvent arg0) {
		printQueryLog();
		clearCache();
		this.disconnect();
	}
	
	public void setSchema(String schema) throws SQLException {
		conn.setCatalog(schema);
		this.schemaName = schema;
		loadData();
	}
	
	private void loadData() {
		
		clearCache();
		
		loadSchema();
		loadTables();
		loadComments();
		loadConstraints();
		loadPrimaryKeys();
		loadForeignKeys();
	}

	private void loadSchema() {
		schemas.clear();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("show databases");	

       		while (rs.next()) {
       			String cat = rs.getString(1);
       			schemas.add(cat);
       			//System.out.println( "catalog: " + cat);       		
       		}
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("loadSchema() Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
	}
		
	private void loadConstraints() {
		constraints.clear();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, ordinal_position from information_schema.KEY_COLUMN_USAGE where constraint_schema='"+ this.getSchemaName()+"' order by 1,2,4");	

       		String prevConName = null;
       		String temp = "";
       		int counter = 0;
       		while (rs.next()) {
       			counter++;
       			String conName = rs.getString(1);
       			String tabName = rs.getString(2);
       			String colName = rs.getString(3);
       			int position = rs.getInt(4);
       			
       			if (position == 1) {
       				// process previous constraint
       				if (prevConName != null) {
       					//temp = temp + ")";
       					constraints.put(prevConName, temp);
       					//System.out.println(prevConName + "," + temp);
       					temp = "";
       				}
       				
       				temp = colName;
       				prevConName = tabName + "." + conName;
       			} else {
       				temp += ", " + colName;
       			}
       		}
       		rs.close();
       		stmt.close();

       		//temp += ")";
			constraints.put(prevConName, temp);

		} catch (SQLException e) {
             System.err.println ("loadConstraints() Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
	}

	private void loadPrimaryKeys() {
		pkByTab.clear();
		pkByCon.clear();

		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select CONSTRAINT_NAME, TABLE_NAME  from information_schema.table_constraints where CONSTRAINT_TYPE = 'PRIMARY KEY' AND constraint_schema='" + this.getSchemaName() + "'");	

       		String prevConName = null;
       		String temp = "";
       		while (rs.next()) {
       			String conName = rs.getString("CONSTRAINT_NAME");
       			String tabName = rs.getString("TABLE_NAME");

       			pkByTab.put(tabName.toUpperCase(), conName);
       			pkByCon.put(conName, tabName);
       			//System.out.println(tabName + "," + conName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("6 Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
 		
	}

	private void loadForeignKeys() {
		foreignKeys.clear();
	
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from information_schema.REFERENTIAL_CONSTRAINTS where constraint_schema='"+this.getSchemaName()+"' order by table_name");	

       		while (rs.next()) {
       			ForeignKey fk = new ForeignKey();
       			fk.owner = rs.getString("constraint_schema");
       			fk.constraintName = rs.getString("CONSTRAINT_NAME");
       			fk.tableName = rs.getString("TABLE_NAME");
       			fk.rTableName = rs.getString("referenced_table_name");
       			fk.rOwner = rs.getString("unique_constraint_schema");
       			fk.rConstraintName =  rs.getString("unique_constraint_name");
       			fk.deleteRule = rs.getString("DELETE_RULE");

       			foreignKeys.add(fk);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("loadForeignKeys() Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
 		
	}

	private void loadComment(String tname) {
		
		// table comments
		try {
       		Statement stmt = conn.createStatement();
       		String qry = "SELECT table_name, table_comment FROM information_schema.TABLES where table_type='BASE TABLE' and table_schema='"+this.getSchemaName()+"' and TABLE_NAME='" + tname + "'";
       		//System.out.println(qry);
       		ResultSet rs = stmt.executeQuery(qry);	

	   		while (rs.next()) {
	   			String tab = rs.getString(1);
	   			String comment = rs.getString(2);
	   			
	   			if (comment != null && tab != null) comments.put(tab, comment);
	       		//System.out.println( tab + ", " + comment);       		
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("loadComment(String tname) Cannot connect to database server");
            message = e.getMessage();
		}

		comment_tables.add(tname);
	}
	
	private void loadComments() {
		comments.clear();
		// table comments
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT table_name, table_comment FROM information_schema.TABLES where table_type='BASE TABLE' and table_schema='"+this.getSchemaName()+"'");	

	   		while (rs.next()) {
	   			String tab = rs.getString(1);
	   			String comment = rs.getString(2);
	   			
	   			if (comment != null && tab != null) comments.put(tab, comment);
	       		//System.out.println( tab + ", " + comment);       		
	   		}
	   		rs.close();
	   		stmt.close();

		} catch (SQLException e) {
            System.err.println ("loadComments() Cannot connect to database server");
            e.printStackTrace();
            message = e.getMessage();
		}
	}
	
	// get table comments
	public String getComment(String tname) {
		String key = tname.trim();

		if (!comment_tables.contains(key))
			loadComment(tname);
		
		String comment = comments.get(key);
		return (comment != null? comment : "");
	}
	
	// get column comments
	public String getComment(String tname, String cname) {

		if (!comment_tables.contains(tname))
			loadComment(tname);
		
		String key = (tname + "." + cname).trim();
		
		String comment = comments.get(key);
		return (comment != null? comment : "");
	}
	
	public String getSynTableComment(String owner, String tname) {
		String res="";
/*		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT COMMENTS FROM ALL_TAB_COMMENTS WHERE OWNER='" + owner +
       				"' AND TABLE_NAME='" + tname + "'");	

       		if (rs.next()) {
       			res = rs.getString("COMMENTS");
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("15 Cannot connect to database server");
             message = e.getMessage();
 		}
*/
		
		if(res==null) res = "";
		return res;
		
	}
	
	public String getSynColumnComment(String owner, String tname, String cname) {
		String res="";
/*		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("SELECT COMMENTS FROM ALL_COL_COMMENTS WHERE OWNER='" + owner +
       				"' AND TABLE_NAME='" + tname + "' AND COLUMN_NAME='" + cname + "'");	

       		if (rs.next()) {
       			res = rs.getString("COMMENTS");
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("16 Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		if(res==null) res = "";
		return res;
		
	}
	
	private void loadTables() {
		tables.clear();
		try {
			DatabaseMetaData dbm = conn.getMetaData();
			String[] types = {"TABLE"};
			ResultSet rs = dbm.getTables(null,schemaName.toUpperCase(),"%",types);
			//	System.out.println("Table name:");
			while (rs.next()){
				String tableSchema = rs.getString(2);
				String tableName = rs.getString("TABLE_NAME");
//				tables.add(tableSchema + "." + table);
				tables.add(tableName);
				
//		        // Get the table name
//		        String tableName = rs.getString(3);
//
//		        // Get the table's catalog and schema names (if any)
//		        String tableCatalog = rs.getString(1);
//		        String tableSchema = rs.getString(2);
//				tables.add(tableName + "|" + tableCatalog + "|" + tableSchema);
				
				//System.out.println(table);
			}
		} catch (SQLException e) {
            System.err.println ("4 Cannot connect to database server");
            message = e.getMessage();
		}
	}
	
	public String genie(String value, String tab, String targetCol, String sourceCol) {
		String res=null;
		
		String qry = "SELECT " + targetCol + " FROM " + tab + " WHERE " + sourceCol + "='" + value ;
		//System.out.println("genie: " +qry);
		
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(qry);
			
			if (rs.next()) {
				res = rs.getString(1);
			}
		
			rs.close();
			stmt.close();
		} catch (SQLException e) {
            System.err.println (e.toString());
		}
		
		return res;
	}
	
	public String genie(String srcCol, String tabCol) {
		String table = "";
		String targetCol = "";
		
		StringTokenizer st = new StringTokenizer(tabCol, "."); 
		table = st.nextToken();
		targetCol = st.nextToken();
	
		return genie(srcCol, table, targetCol, srcCol);
	}
	
	public String genie(String srcCol, String tabTargetCol, String tabSrcCol) {
		String table = "";
		String targetCol = "";
		
		StringTokenizer st = new StringTokenizer(tabTargetCol, "."); 
		table = st.nextToken();
		targetCol = st.nextToken();
	
		return genie(srcCol, table, targetCol, tabSrcCol);
	}
//	
//	public String getPrimaryKey(String catalog, String tname)  {
//		String colName = "";
//		
//		String key = catalog + "." + tname;
//		colName = (String) pkColumn.get(key);
//		if (colName != null) return colName;
//		
//		DatabaseMetaData dbm;
//		try {
//			dbm = conn.getMetaData();
//
//			// primary key
//			ResultSet rs = dbm.getPrimaryKeys(catalog, null, tname);
//			if (rs.next()){
//				colName = rs.getString("COLUMN_NAME");
//			}
//			rs.close();
//			
//			pkColumn.put(key, colName);
//			System.out.println("PK for " + catalog + "." + tname + " is " + colName);
//
//		} catch (SQLException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//
//		return colName;
//	}

	public ArrayList<String> getPrimaryKeys(String catalog, String tname)  {
		ArrayList pk = null;
		String colName = "";
		
		String key = catalog + "." + tname;
		pk = pkMap.get(key);
		if (pk != null) return pk;
		
		DatabaseMetaData dbm;
		try {
			dbm = conn.getMetaData();

			// primary key
			pk = new ArrayList<String>();
			ResultSet rs = dbm.getPrimaryKeys(catalog, null, tname);
			while (rs.next()){
				colName = rs.getString("COLUMN_NAME");
				pk.add(colName);
			}
			rs.close();
			
			pkMap.put(key, pk);
			//System.out.println("PK for " + catalog + "." + tname + " is " + colName);

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			return null;
		}

		return pk;
	}
	
	public String getQueryValue(String sql)  {
		String res = "";
		
		res = (String) queryResult.get(sql);
		if (res != null) return res;

		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(sql);
			
			if (rs.next()) {
				res = rs.getString(1);
			}
			rs.close();
			stmt.close();
			
			if (res!= null)	queryResult.put(sql, res);
			//System.out.println(sql + " => " + res);
			
		} catch (SQLException e) {
			res = e.getMessage();
		}
		
		return res;
	}
/*	
	public ResultSet getQueryRS(String sql)  {
		ResultSet rs = null;
		
		try {
			Statement stmt = conn.createStatement();
			rs = stmt.executeQuery(sql);
			
			return rs;
		} catch (SQLException e) {
			rs = null;
		}
		
		return rs;
	}
*/	
	public void addQueryHistory(String qry) {
		QueryLog ql = new QueryLog(qry);
		queryLog.put(qry, ql);
	}
	
	public HashMap<String,QueryLog> getQueryHistory() {
		return queryLog;
	}
	
	public void ping() {
		String qry = "SELECT 1 from dual";
		try {
			Statement stmt = conn.createStatement();
			ResultSet rs = stmt.executeQuery(qry);
			
			rs.close();
			stmt.close();
		} catch (SQLException e) {
            System.err.println (e.toString());
		}
	}

	public String getPrimaryKeyName(String tname) {
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getPrimaryKeyName(temp[0], temp[1]);
		}
		
		String pkName = pkByTab.get(tname.toUpperCase());
		
		// check for Synonym
		if (pkName == null) {
			String syn=getSynonym(tname) ;
			if (syn != null && syn.contains(".")) {
				return getPrimaryKeyName(syn);
			}
		}		
		
		return pkName;
	}

	public String getPrimaryKeyName(String owner, String tname) {
		String qry = "SELECT CONSTRAINT_TYPE FROM information_schema.TABLE_CONSTRAINTS WHERE constraint_schema='" +
				owner + "' AND TABLE_NAME='" + tname + "' AND CONSTRAINT_TYPE = 'PRIMARY KEY'";
		
		return queryOne(qry);
	}
/*
	public String getTableNameByPrimaryKey(String kname) {
		String tName = pkByCon.get(kname.toUpperCase());
		
		// check for other owner
		if (tName == null) {
			String owner = this.queryOne("SELECT table_schema FROM information_schema.table_constraints WHERE CONSTRAINT_NAME='" + kname +"'");
			return getTableNameByPrimaryKey(owner, kname);
		}
		
		return tName;
	}

	public String getTableNameByPrimaryKey(String owner, String kname) {
		if (owner==null) return this.getTableNameByPrimaryKey(kname);

		String qry = "SELECT OWNER||'.'||TABLE_NAME FROM ALL_CONSTRAINTS WHERE OWNER='" +
				owner + "' AND CONSTRAINT_NAME='" + kname + "'";
		return this.queryOne(qry);
	}
*/
	public List<String> getConstraintColList(String tname, String cname) {
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getConstraintColList(temp[0], temp[1], cname);
		}
		
		// check for other owner
		//String owner = this.queryOne("SELECT constraint_schema FROM information_schema.KEY_COLUMN_USAGE WHERE table_name='"+ tname +"' AND CONSTRAINT_NAME='" + cname +"'");
		String owner = this.getSchemaName();
		if (owner != null) {
			return getConstraintColList(owner, tname, cname);
		}
		
		return getConstraintColList(this.getSchemaName(), tname, cname);
	}

	public List<String> getConstraintColList(String owner, String tname, String cname) {
		if (owner == null) owner = this.getSchemaName().toUpperCase();
		
		List<String> list = new ArrayList<String>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select column_name from information_schema.KEY_COLUMN_USAGE where " +
       				"constraint_schema='" + owner + "' AND table_name='"+tname +"' AND constraint_name='" + cname + "' order by ordinal_position");	

       		while (rs.next()) {
       			String colName = rs.getString(1);
       			list.add(colName);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("getConstraintColList - Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}

	public String getConstraintCols(String tname, String cname) {
		if (cname == null) return "";
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getConstraintCols(temp[0], temp[1], cname);
		}
		
		String cols = constraints.get(tname + "." + cname);
		
		// check for other owner
		if (cols==null) {
			String owner = this.queryOne("SELECT constraint_schema FROM information_schema.table_constraints WHERE table_name='" + tname + "' AND CONSTRAINT_NAME='" + cname +"'");
			if (owner != null) {
				return getConstraintCols(owner, cname);
			}
		}
		
		if (cols==null) cols = "";
		return cols;
	}

	public String getConstraintCols(String owner, String tname, String cname) {
		
		if (owner == null) return getConstraintCols(tname, cname);
		
		String res = "";
		String qry = "SELECT COLUMN_NAME from information_schema.KEY_COLUMN_USAGE where constraint_schema='"+owner+"' AND table_name='"+tname+"' AND CONSTRAINT_NAME='" + cname 
				+ "' ORDER BY ordinal_position";
		
		List<String> list = queryMulti(qry);

		for (int i=0; i<list.size(); i++) {
			if (i==0) res = list.get(i);
			else res +=", " + list.get(i);
		}
		
		return res;
	}

	public List<ForeignKey> getForeignKeys(String tname) {
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getForeignKeys(temp[1]);
		}
		
		List<ForeignKey> list = new ArrayList<ForeignKey>();
		
		for (int i=0; i<foreignKeys.size(); i++) {
			ForeignKey fk = foreignKeys.get(i);
			if (fk.tableName.equalsIgnoreCase(tname)) {
				list.add(fk);
			}
		}
		
		// check for Synonym table
		if (list.size()==0) {
			String syn = getSynonym(tname);
//			System.out.println("syn="+syn);
			if (syn != null && syn.contains(".")) {
				return getForeignKeys(syn);
			}
		}
					
		return list;
	}

	public List<ForeignKey> getForeignKeys(String owner, String tname) {
		return getForeignKeys(tname);
	}
/*	
	public List<ForeignKey> getForeignKeys(String owner, String tname) {
		List<ForeignKey> list = new ArrayList<ForeignKey>();
//System.out.println("owner,tname=" + owner + "," + tname);		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select * from all_constraints where CONSTRAINT_TYPE = 'R' " +
       				"AND owner='" + owner + "' AND table_name='" + tname + "' order by table_name, constraint_type");	

       		while (rs.next()) {
       			ForeignKey fk = new ForeignKey();
       			fk.owner = rs.getString("OWNER");
       			fk.constraintName = rs.getString("CONSTRAINT_NAME");
       			fk.tableName = rs.getString("TABLE_NAME");
       			fk.rOwner = rs.getString("R_OWNER");
       			fk.rConstraintName = rs.getString("R_CONSTRAINT_NAME");
       			fk.deleteRule = rs.getString("DELETE_RULE");

       			list.add(fk);
       		}
       		rs.close();
       		stmt.close();

		} catch (SQLException e) {
             System.err.println ("getForeignKeys - Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
*/
	
	public List<String> getReferencedTables(String tname) {
		
		if (tname.contains(".")) {
			String[] temp = tname.split("\\.");
			return getReferencedTables(temp[0], temp[1]);
		}
		
		List<String> list = new ArrayList<String>();

		String pkName = getPrimaryKeyName(tname);
		if (pkName == null) return list;
		
		for (int i=0; i<foreignKeys.size(); i++) {
			ForeignKey fk = foreignKeys.get(i);
			if (fk.rConstraintName.equals(pkName) && fk.rTableName.equals(tname)) {
				list.add(fk.tableName);
			}
		}
		
		// check for synonym
		if (list.size()==0) {
			String syn = getSynonym(tname);
//System.out.println("*** syn=" + syn);			
			if (syn != null && syn.contains(".")) {
				return getReferencedTables(syn);
			}
		}
		
		// sort by table name and remove dups.
		Set <String> set = new HashSet<String>(list);
		
		List<String> list2 = new ArrayList<String>(set);
		Collections.sort(list2);
		
		return list2;
	}

	public List<String> getReferencedTables(String owner, String tname) {
		if (owner == null) return getReferencedTables(tname);
		
		String pkName = getPrimaryKeyName(owner, tname);
		
		String qry = "SELECT concat(constraint_schema,'.',TABLE_NAME) FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE " +
				"tabke_name='" + tname + "' AND CONSTRAINT_NAME='" + pkName +"' ORDER BY TABLE_NAME";
		
		return this.queryMultiUnique(qry);
	}

	
	public List<String> getReferencedPackages(String tname) {
		List<String> list = new ArrayList<String>();
/*
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TYPE BODY','PACKAGE BODY','PACKAGE','TYPE','PROCEDURE','FUNCTION') ORDER BY NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getReferencedPackages() Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
*/		
		return list;
	}
	
	public List<String> getReferencedViews(String tname) {
		List<String> list = new ArrayList<String>();
/*
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('VIEW') ORDER BY NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("11 Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		return list;
	}
	
	public List<String> getIndexes(String owner, String tname) {
		List<String> list = new ArrayList<String>();

		if (owner == null) owner = this.getSchemaName().toUpperCase();
		try {
			Statement stmt = conn.createStatement();
			String qry = "SELECT index_name, non_unique FROM information_schema.statistics WHERE table_name='" + tname + "' AND table_schema='" + owner +"' AND INDEX_NAME NOT IN ('PRIMARY')";
			System.out.println(qry);
			ResultSet rs = stmt.executeQuery(qry);

			while (rs.next()) {
				String indexName = rs.getString(1);
				
//				String t = getTableNameByPrimaryKey(indexName);
//				if (t != null) continue; // skip if PK

				String non_unique = rs.getString(2);
//				if (unique.equals("0")) unique="";
				if (!list.contains(indexName))
					list.add(indexName);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getIndexes() Cannot connect to database server");
             e.printStackTrace();
             message = e.getMessage();
 		}
		
		return list;
	}
	
	public List<String> getReferencedTriggers(String tname) {
		List<String> list = new ArrayList<String>();
/*
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct NAME from user_dependencies WHERE REFERENCED_NAME='" + tname + "' AND TYPE IN ('TRIGGER') ORDER BY NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String name = rs.getString("NAME");
       			list.add(name);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("12 Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		return list;
	}
	
	public String getIndexColumns(String owner, String tname, String iname) {
		String res = "(";

		if (owner == null) owner = this.getSchemaName().toUpperCase();
		try {
       		Statement stmt = conn.createStatement();
       		
			String qry = "SELECT column_name FROM information_schema.statistics WHERE table_name='" + tname + "' AND table_schema='" + owner +"' AND INDEX_NAME = '" + iname + "' order by seq_in_index";
System.out.println(qry);
       		ResultSet rs = stmt.executeQuery(qry);	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String cname = rs.getString("COLUMN_NAME");
       			if (count > 1) res +=", ";
       			res += cname;
       		}
       		
       		res +=")";
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getIndexColumns - ");
             message = e.getMessage();
 		}

		return res;
	}
	
	public String getDependencyPackage(String owner, String name) {
		String res = "";
/*		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('PACKAGE','FUNCTION','PROCEDURE','TYPE') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;
       			res += "<a href='javascript:loadPackage(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencyPackage() Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		return res;
	}

	public String getDependencyTable(String owner, String name) {
		String res = "";
/*
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('TABLE') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadTable(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("10 Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		return res;
	}

	public String getDependencyView(String owner, String name) {
		String res = "";
/*		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' AND NAME='" + name + "' AND REFERENCED_TYPE IN ('VIEW') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadView(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencyView - Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		return res;
	}

	public String getDependencySynonym(String owner, String name) {
		String res = "";
/*		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery("select distinct REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE from all_dependencies WHERE OWNER='" + owner + "' and NAME='" + name + "' AND REFERENCED_TYPE IN ('SYNONYM') AND REFERENCED_OWNER != 'PUBLIC' ORDER BY REFERENCED_NAME");	

       		int count = 0;
       		while (rs.next()) {
       			count ++;
       			String rowner = rs.getString("REFERENCED_OWNER");
       			String rname = rs.getString("REFERENCED_NAME");
       			String rtype = rs.getString("REFERENCED_TYPE");
       			
       			if(!rowner.equalsIgnoreCase(this.getSchemaName()))
       				rname = rowner + "." + rname;

       			res += "<a href='javascript:loadSynonym(\""+ rname + "\")'>" + rname + "</a>&nbsp;&nbsp;<br/>";
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("getDependencySynonym - Cannot connect to database server");
             message = e.getMessage();
 		}
*/		
		return res;
	}

	public String queryOne(String qry, boolean useCache) {
		//System.out.println("queryOne="+qry);

		String res = stringCache.get(qry);
		if (res != null && useCache) return res;
		
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		if (rs.next()) {
       			res = rs.getString(1);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryOne - " + qry);
             message = e.getMessage();
 		}
		stringCache.add(qry, res);
		return res;
	}


	public String queryOne(String qry) {
		return queryOne(qry, true);
	}
	

	public List<String> queryMulti(String qry) {
		return queryMulti(qry, true);
	}
		
	public List<String> queryMulti(String qry, boolean useCache) {
		
		List<String> list = null;
		
		if (useCache) {
			list = listCache.getListObject(qry);
			if (list != null) return list;
		}
		
		list = new ArrayList<String>();
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	

       		while (rs.next()) {
       			String res = rs.getString(1);
       			list.add(res);
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryMulti - " + qry);
             message = e.getMessage();
 		}
		
		if (useCache) listCache.addList(qry, list);
		return list;
	}

	public List<String> queryMultiUnique(String qry) {
		List <String> list = queryMulti(qry);
		HashSet<String> set = new HashSet<String>(list);
		
		List <String> newList = new ArrayList<String>(set);
		
		return newList;
	}

	public String getSynonym(String sname) {
		return "";
/*		
		String qry = "SELECT table_owner||'.'||table_name FROM user_synonyms where synonym_name='" + sname + "'";
		return this.queryOne(qry);
*/		
	}
	
	public int getPKLinkCount(String tname, String cols, String keys) {
		int cnt = 0;
		
		String condition = Util.buildCondition(cols,  keys);
		String qry = "SELECT COUNT(*) FROM " + tname + " WHERE " + condition;

		String res = this.queryOne(qry);
		cnt = Integer.parseInt(res);
		
		return cnt;
	}

	public String getRelatedLinkSql(String tname, String cols, String keys) {
		
		String condition = Util.buildCondition(cols,  keys);
		String qry = "SELECT * FROM " + tname + " WHERE " + condition;

		return qry;
	}

	public String getPKLinkSql(String tname, String keys) {
		String qry="SELECT * FROM " + tname;

		// Primary Key for PK Link
		String pkName = getPrimaryKeyName(tname);
		String pkCols = null;
		String pkColName = null;
		int pkColIndex = -1;
		if (pkName != null) {
			pkCols = getConstraintCols(tname, pkName);
			int colCount = Util.countMatches(pkCols, ",") + 1;
//			System.out.println("pkCols=" + pkCols + ", colCount=" + colCount);
			pkColName = pkCols;
		}

		String condition = Util.buildCondition(pkColName,  keys);
		qry += " WHERE " + condition;
		
		return qry;
	}
	public String getObjectType(String oname) {
		if (oname.contains(".")) {
			String[] temp = oname.split("\\.");
			return getObjectType(temp[0], temp[1]);
		}
		
		String qry = "SELECT OBJECT_TYPE FROM USER_OBJECTS WHERE OBJECT_NAME='" + oname + "'";
		return queryOne(qry);
	}

	public String getObjectType(String owner, String oname) {
		String qry = "SELECT OBJECT_TYPE FROM ALL_OBJECTS WHERE OWNER='" + owner + "' AND OBJECT_NAME='" + oname + "'";
		return queryOne(qry);
	}

	/**
	 * 
	 * @return true if connected user has DBA role
	 */
	public boolean hasDbaRole() {
		
		String qry = "SELECT GRANTED_ROLE FROM USER_ROLE_PRIVS WHERE GRANTED_ROLE='DBA'";
		String dba = this.queryOne(qry);
		
		if (dba.equals("DBA")) return true;
		
		return false;
	}
	
	public List<TableCol> getTableDetail(String owner, String tname) throws SQLException {
		List<TableCol> list = tableDetailCache.get(owner, tname); 
		if (list != null ) return list;
		
		list = new ArrayList<TableCol>();

    	DatabaseMetaData dbm = conn.getMetaData();
        ResultSet rs1 = dbm.getColumns(owner,"%",tname,"%");
		// primary key
		ArrayList<String> pk = getPrimaryKeys(owner, tname);
		
		//System.out.println("Detail for " + table);
		while (rs1.next()){
			String colName = rs1.getString("COLUMN_NAME");
        	String dataType = rs1.getString("TYPE_NAME");
        	String remarks = rs1.getString("REMARKS");
        	int dataSize = rs1.getInt("COLUMN_SIZE");
        	int nullable = rs1.getInt("NULLABLE");
			
			String colDef = rs1.getString("COLUMN_DEF");
			if (colDef==null) colDef="";
			
			String dType = dataType.toLowerCase();
			
			if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
				dType += "(" + dataSize + ")";
/*
String cols[] = {"COLUMN_NAME", "DATA_TYPE","TYPE_NAME","COLUMN_SIZE","DECIMAL_DIGITS",
		"NUM_PREC_RADIX","NULLABLE","REMARKS","COLUMN_DEF"};	
			
for (String col : cols) {
	System.out.println(col + "="+rs1.getString(col));			
	
}
*/
			
			TableCol rec = new TableCol();
			rec.setName(colName);
			rec.setType(dataType);
			rec.setSize(dataSize);
//			rec.setDecimalDigits(decimalDigits);
			rec.setNullable(nullable);
			rec.setDefaults(colDef);
			rec.setTypeName(dType);
			rec.setPrimaryKey(pk.contains(colName));
			rec.setRemarks(remarks);

			list.add(rec);
		}
		
		rs1.close();
		
		tableDetailCache.add(owner, tname, list);
		return list;
	}

/*	
	public List<TableCol> getTableDetail(String catalog, String tname) throws SQLException {
		List<TableCol> list = new ArrayList<TableCol>();

		DatabaseMetaData dbm = conn.getMetaData();
		ResultSet rs1 = dbm.getColumns(catalog,"%",tname,"%");

		// primary key
		ArrayList<String> pk = getPrimaryKeys(catalog, tname);
		
		//System.out.println("Detail for " + table);
		while (rs1.next()){
			String colName = rs1.getString("COLUMN_NAME");
			String dataType = rs1.getString("TYPE_NAME");
			int dataSize = rs1.getInt("COLUMN_SIZE");
			int decimalDigits = rs1.getInt("DECIMAL_DIGITS");
			int nullable = rs1.getInt("NULLABLE");
			
			String nulls = (nullable==1)?"":"N";
			String colDef = rs1.getString("COLUMN_DEF");
			if (colDef==null) colDef="";
			
			String dType = dataType.toLowerCase();
			
			if (dType.equals("varchar") || dType.equals("varchar2") || dType.equals("char"))
				dType += "(" + dataSize + ")";

			if (dType.equals("number")) {
				if (dataSize > 0 && decimalDigits > 0)
					dType += "(" + dataSize + "," + decimalDigits +")";
				else if (dataSize > 0)
					dType += "(" + dataSize + ")";
			}

			TableCol rec = new TableCol();
			rec.setName(colName);
			rec.setType(dataType);
			rec.setSize(dataSize);
			rec.setDecimalDigits(decimalDigits);
			rec.setNullable(nullable);
			rec.setDefaults(colDef);
			rec.setTypeName(dType);
			rec.setPrimaryKey(pk.contains(colName));

			list.add(rec);
		}
		
		return list;
	}
*/
	

	public List<String[]> queryMultiCol(String qry, int cols) {
		return queryMultiCol(qry, cols, true);
	}
	
	public List<String[]> queryMultiCol(String qry, int cols, boolean useCache) {
		
		List<String[]> list = null;
		if (useCache) {
			list = listCache2.getListObject(qry);
			if (list != null) return list;
		}
		
		list = new ArrayList<String[]>();
		int cnt = 0;
		try {
       		Statement stmt = conn.createStatement();
       		ResultSet rs = stmt.executeQuery(qry);	
    		
       		if (cols == 0) {
    			cols = rs.getMetaData().getColumnCount();
    		}
    		
       		while (rs.next()) {
       			String res[] = new String[cols+1];
       			
       			for (int i=1; i<=cols;i++)
       				res[i] = rs.getString(i);
       			list.add(res);
       			cnt++;
       			if (cnt >= 10000) break;       			
       		}
       		
       		rs.close();
       		stmt.close();
		} catch (SQLException e) {
             System.err.println ("queryMultiCol - " + qry);
             message = e.getMessage();
 		}
		
		if (useCache) listCache2.addList(qry, list);
		return list;
	}
	
	public String getRefConstraintCols(String master, String detail) {
		// get master table's PK name
		String pkName = this.getPrimaryKeyName(master);
//System.out.println("pkName=" + pkName);		
		// get foreign key list
		List<ForeignKey> fks = this.getForeignKeys(detail);
		
		for (ForeignKey fk : fks) {
			if (fk.rConstraintName.equals(pkName) && fk.rTableName.equals(master)) {
//				System.out.println("fk.tableName=" + fk.tableName);		
				return this.getConstraintCols(fk.tableName, fk.constraintName);
			}
		}
		
		return "";
	}
	
	
	public void clearCache() {
		if (queryCache!=null) queryCache.clearAll();
		if (listCache!=null) listCache.clearAll();
		if (listCache2!=null) listCache2.clearAll();
		if (stringCache!=null) stringCache.clearAll();
		if (tableDetailCache!=null) tableDetailCache.clearAll();
	}

	
	public void createTable() throws SQLException {
        conn.setReadOnly(false);

		String stmt1 = 
				"CREATE TABLE GENIE_PAGE (	"+
				"PAGE_ID	VARCHAR(100),"+
				"TITLE		VARCHAR(100),"+
				"PARAM1	VARCHAR(100),"+
				"PARAM2	VARCHAR(100),"+
				"PARAM3	VARCHAR(100),"+
				"PRIMARY KEY (PAGE_ID) ) ENGINE=InnoDB;";
			
		String stmt2 = 
				"CREATE TABLE GENIE_PAGE_SQL (	"+
				"PAGE_ID	VARCHAR(100)," +
				"SEQ		INT,"+
				"TITLE		VARCHAR(100),"+
				"SQL_STMT	VARCHAR(1000),"+
				"INDENT	INT		DEFAULT 0,"+
				"PRIMARY KEY (PAGE_ID, SEQ),"+
				"CONSTRAINT FOREIGN KEY (PAGE_ID) REFERENCES GENIE_PAGE(PAGE_ID) ON DELETE CASCADE) ENGINE=InnoDB;";

		Statement stmt = conn.createStatement();
		stmt.execute(stmt1);
		stmt.execute(stmt2);
		stmt.close();
		
		stmt = conn.createStatement();
		String sql = "INSERT INTO GENIE_PAGE VALUES ('TABLE','User Defined Page Sample','tname',null,null)";
		stmt.executeUpdate(sql);

		sql = "INSERT INTO GENIE_PAGE_SQL VALUES ('TABLE',1, 'Table Detail', 'SELECT * FROM USER_TABLES WHERE TABLE_NAME=upper(''[tname]'')',0)";
		stmt.executeUpdate(sql);

		sql = "INSERT INTO GENIE_PAGE_SQL VALUES ('TABLE',2, 'Column List', 'SELECT * FROM USER_TAB_COLUMNS WHERE TABLE_NAME=upper(''[tname]'') ORDER BY COLUMN_ID',30)";
		stmt.executeUpdate(sql);
		
		sql = "INSERT INTO GENIE_PAGE_SQL VALUES ('TABLE',3, 'Indexes', 'SELECT * FROM USER_INDEXES WHERE TABLE_NAME=upper(''[tname]'')',30)";
		stmt.executeUpdate(sql);
		
		stmt.close();
        conn.setReadOnly(false);
	}
}
