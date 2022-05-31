public class DrawloopDocumentGeneration {
    public static void drawloopDocumentGeneration(){
        try{
            Loop.loopMessage lm = new Loop.loopMessage();
            for(Opportunity bps : [Select Id from Opportunity Where Id = '0063M00000659xtQAA'])
            {
                Map<string, string> variables;
                lm.requests.add(new Loop.loopMessage.loopMessageRequest(
                    bps.Id, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
                    //'a5q0U0000000Wgr' -> Id of Document package
                    //'a5o0U00000002hI' -> Id of delivery option of this Document package
                    'a1p3M000000CevY',
                    new Map<string, string> { 'deploy' => 'a1n3M000000CbCP' }
                ));
            }
            system.debug('--------lm-----:'+lm);
            // SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
            lm.sendAllRequests();
        }
        catch(Exception e){
            system.debug('--------e-----:'+e);
        }
    }
}