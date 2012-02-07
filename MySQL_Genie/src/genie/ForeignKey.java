package genie;

/**
 * Record definition for foreign key
 * 
 * @author spencer.hwang
 *
 */
public class ForeignKey {
	public String owner;
	public String constraintName;
	public String tableName;
	public String rTableName;
	public String rOwner;
	public String rConstraintName;
	public String deleteRule;
}
