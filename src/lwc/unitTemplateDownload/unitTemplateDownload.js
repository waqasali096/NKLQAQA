import {  LightningElement,  track, api  } from "lwc";  
import getUnits from "@salesforce/apex/ExportToExcelController.getUnits";  
  const columns = [{  
      label: "Unit Code",  
      fieldName: "UnitNumber",  
      type: "text"  
    },  
    {  
      label: "Selling Price",  
      fieldName: "UnitPrice",  
      type: "Decimal"  
    },
    {  
        label: "Status",  
        fieldName: "Status",  
        type: "text"  
      },
      {  
        label: "Project Name",  
        fieldName: "ProjectName",  
        type: "text"  
      },
      
  ];  

export default class UnitTemplateDownload extends LightningElement {
    @api recordId;
    @track hrefdata;  
    @track unitList;  
    @track unitColumns = columns; 
    
    async connectedCallback() {
        setTimeout(() => {
            //alert('***'+this.recordId);
            getUnits({PricebookId: this.recordId}).then(result => {  
                this.unitList = result;  
              })  
              .catch(error => {  
                this.error = error;  
                console.log(this.error);  
              });   
        },5);
    }  
    
    exportToCSV() {  
      let columnHeader = ["UnitCode", "Price","Status","Project Name"];  // This array holds the Column headers to be displayd
      let jsonKeys = ["UnitNumber", "UnitPrice","Status","ProjectName"]; // This array holds the keys in the json data  
      var jsonRecordsData = this.unitList;  
      let csvIterativeData;  
      let csvSeperator  
      let newLineCharacter;  
      csvSeperator = ",";  
      newLineCharacter = "\n";  
      csvIterativeData = "";  
      csvIterativeData += columnHeader.join(csvSeperator);  
      csvIterativeData += newLineCharacter;  
      for (let i = 0; i < jsonRecordsData.length; i++) {  
        let counter = 0;  
        for (let iteratorObj in jsonKeys) {  
          let dataKey = jsonKeys[iteratorObj];  
          if (counter > 0) {  csvIterativeData += csvSeperator;  }  
          if (  jsonRecordsData[i][dataKey] !== null &&  
            jsonRecordsData[i][dataKey] !== undefined  
          ) {  csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
          } else {  csvIterativeData += '""';  
          }  
          counter++;  
        }  
        csvIterativeData += newLineCharacter;  
      }  
      console.log("csvIterativeData", csvIterativeData);  
      this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);  
    }  
}