package genie;

public class DataDef  {
	String value;
	boolean isNull = false;

	static String numberTypes[] = {"NUMBER", "INTEGER", "SMALLINT", "BIGINT", "FLOAT", "BOUBLE"};
	
	public int compareTo(DataDef target, String typeName) {
		
		if (this.isNull) return -1;
		if (target.isNull) return 1;

		boolean isNumberType = false;
		for (String tName: numberTypes) {
			if (typeName.startsWith(tName)) {
				isNumberType = true;
				break;
			}
		}
		
		if (isNumberType) {
			double d1 = Double.valueOf(this.value);
			double d2 = Double.valueOf(target.value);
			
			if (d1 > d2)
				return 1;
			else
				return -1;
		}
		
		return this.value.compareTo(target.value);
	}
}
