package genie;

import java.sql.Blob;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class QueryData {

	ArrayList<ColumnDef> columns = new ArrayList<ColumnDef>();
	ArrayList<RowDef> rows = new ArrayList<RowDef>();
	
	public void setColumns(ResultSet rs) throws SQLException {
		for  (int i = 1; i<= rs.getMetaData().getColumnCount(); i++){
			ColumnDef cDef = new ColumnDef();
			cDef.columnLabel = rs.getMetaData().getColumnLabel(i);
			cDef.columnType =  rs.getMetaData().getColumnType(i);
			cDef.columnTypeName = rs.getMetaData().getColumnTypeName(i);
			cDef.columnName = rs.getMetaData().getColumnName(i);
			cDef.tableName = rs.getMetaData().getTableName(i);

			columns.add(cDef);
			
//			System.out.println("cDef.columnLabel="+cDef.columnLabel);
//			System.out.println("cDef.columnType="+cDef.columnType);
//			System.out.println("cDef.columnTypeName="+cDef.columnTypeName);
//			System.out.println("cDef.columnName="+cDef.columnName);
//			System.out.println("cDef.tableName="+cDef.tableName);
		}
	}
	
	public void setData(ResultSet rs) throws SQLException {
		int cnt=0;
		while (rs.next()) {
			RowDef aRow = new RowDef();
			cnt ++;
			
			for  (int i = 0; i< rs.getMetaData().getColumnCount(); i++){
				DataDef data = new DataDef();
				data.value = getValue(rs, i);
				if (data.value==null) data.isNull = true;
				aRow.row.add(data);
			}
			rows.add(aRow);
			if (cnt>=1000) break;
		}
//		System.out.println("Record Count=" + cnt);
	}
	
	private String getValue(ResultSet rs, int idx) {
		String val="";
		int colInd = idx +1;
		try {
			int cType = columns.get(idx).columnType;
			
			if (cType==2004) {	// BLOB
				val="BLOB";
				
				Blob blob = rs.getBlob(colInd);
				if (blob==null) {
					val = null;
				} else {
					val = "BLOB size=" + blob.length();
				}

			} else
				val = rs.getString(colInd);
		} catch (SQLException e) {
			val = e.getMessage();
			int cType = columns.get(idx).columnType;
			System.err.print("Column type: " + cType);
		}
		
		if (val != null && val.endsWith(" 00:00:00.0")) val = val.substring(0, val.length()-11);
		
		return val;
	}

	public int getColumnIndex(String cName) {
		for (int i=0; i<columns.size();i++) {
			ColumnDef cDef = columns.get(i);
			if (cDef.columnLabel.equalsIgnoreCase(cName)) return i;
		}
		
		return -1;
	}
	
}
