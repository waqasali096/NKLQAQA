/**************************************************************************************************
* Name               : nklErrorPanel.js                                              
* Description        : JS controller for nklErrorPanel component.                           
* Created Date       : 17/10/2021
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       14/10/2021      Initial Draft.                                           
**************************************************************************************************/
import { api, LightningElement } from 'lwc';

export default class NklErrorPanel extends LightningElement {
    @api errorMessage;
}