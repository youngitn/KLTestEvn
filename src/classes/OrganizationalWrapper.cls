global class OrganizationalWrapper implements Comparable {

    public Organizational__c org{GET;SET;}
    
    // Constructor
    public OrganizationalWrapper(Organizational__c op) {
        org = op;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OrganizationalWrapper
        OrganizationalWrapper compareToOppy = (OrganizationalWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (org.Approval_Step__c > compareToOppy.org.Approval_Step__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (org.Approval_Step__c < compareToOppy.org.Approval_Step__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}