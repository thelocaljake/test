trigger AccountTrigger on Account (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	if( Trigger.isAfter ){
		if( Trigger.isInsert ){
			//create junction objects
			AccountTriggerHandler.createJunctionObjects( Trigger.new );
		}
	}
}