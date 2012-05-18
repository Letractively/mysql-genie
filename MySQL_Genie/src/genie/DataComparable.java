package genie;

import java.util.Comparator;

public class DataComparable /* implements Comparator<DataComparable> */{
	boolean isNull = false;
	boolean isNumberType = false;
	String valueS;
	double valueD=0;
	int index;
	
	
	public DataComparable(String value, boolean isNull, boolean isNumber, int index) {
		valueS = value;
		this.isNull = isNull;
		this.index = index;
		this.isNumberType = isNumber;
		
		if (isNumber && !isNull) {
			valueD = Double.parseDouble(value);
		}
	}
	
	public double getNumberValue() {
		return valueD;
	}
	
	public String getStringValue() {
		return valueS;
	}
	
	public int getIndex() {
		return index;
	}

/*	
	@Override
	public int compare(DataComparable o1, DataComparable o2) {

		if (o1.isNull) return -1;
		if (o1.isNumberType) return (int) (o1.getNumberValue() - o2.getNumberValue()); 
		
		return o1.getStringValue().compareTo(o2.getStringValue());
	}
*/
}
