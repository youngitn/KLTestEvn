const j$ = jQuery.noConflict();
            const lookupId = 'j_id0:j_id15:form:Toastmaster';
        	j$( function() {
        		
   
                j$( ".btn").removeClass('btn');
                j$( ".dateInput").removeClass('dateInput'); 
                j$( ".dateOnlyInput").removeClass('dateOnlyInput');
                j$( "#tabs" ).tabs({
                  beforeLoad: function( event, ui ) {
                    ui.jqXHR.fail(function() {
                      ui.panel.html(
                        "Couldn't load this tab. We'll try to fix this as soon as possible. " +
                        "If this wouldn't be a demo." );
                    }); 
                  }
                });


                let g = 'var script = document.createElement("script");'+
    					'script.src = "https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js";'+
    					'document.head.appendChild(script);';

	            // j$( "input[id$=Toastmaster]").on('click',function(){
	            //     	var myWindow =  openLookup('/_ui/common/data/LookupPage?lkfm=j_id0:j_id15:form&lknm=j_id0:j_id15:form:Toastmaster&lktp=003','&lksrch=' + escapeUTF(getElementByIdCS('j_id0:j_id15:form:Toastmaster').value.substring(0, 80)));
	                	
	            //     });

	            
	      		//將input加入能夠選取連絡人功能      		
	            createLookUpFiled('j_id0:j_id12:form','Toastmaster','lookupInput');
	            createLookUpFiled('j_id0:j_id12:form','Note_Taker__c','lookupInput2');


        	}  );    

        	function htmlencode(s){  
			    var div = document.createElement('div');  
			    div.appendChild(document.createTextNode(s));  
			    return div.innerHTML;  
			}  
			function htmldecode(s){  
			    var div = document.createElement('div');  
			    div.innerHTML = s;  
			    return div.innerText || div.textContent;  
			}  
            
            //讓一般的文字輸入也能出現連絡人選取視窗
            function createLookUpFiled(formId,inputId,appendId){

				let lastStr = [
					"_lkid",
					"_lkold",
					"_lktp",
					"_lspf",
					"_lspfsub",
					"_mod"];
				let defVal = [
					"000000000000000",
					"null",
					"003",
					"0",
					"0",
					"0"];

				let i ;

				for (i = 0; i <= 5; i++) { 
				    let template = j$( "<input>", 
					{ 	id: formId+":"+inputId+lastStr[i], 
						// html:$( "<div>", 
						// 		{ 	class: "bar", 
						// 			text: "bla" 
						// 		} )
						type:"hidden",
						name:formId+":"+inputId+lastStr[i],
						value:defVal[i]
					});

					j$('#'+appendId).append(template);
				} 
				template = null;
				template = j$( "<a>", 
					{ 	id: formId+":"+inputId+lastStr[i], 
						html:j$( "<img>", 
								{ 	
									src:"/img/s.gif",
									alt:"员工 對應 (新視窗)",
									class:"lookupIcon",
									onblur:"this.className = 'lookupIcon';" ,
									onfocus:"this.className = 'lookupIconOn';",
									onmouseout:"this.className = 'lookupIcon';this.className = 'lookupIcon';" ,
									onmouseover:"this.className = 'lookupIconOn';this.className = 'lookupIconOn';",
									title:"员工 對應 (新視窗)"

									
								} ),
						
						href:"javascript:openLookup('/_ui/common/data/LookupPage?lkfm="+formId+"&lknm="+formId+":"+inputId+"&lktp=003','&lksrch=' + escapeUTF(getElementByIdCS('"+formId+":"+inputId+"').value.substring(0, 80)))",
						id:formId+":"+inputId+"_lkwgt",
						onclick:"setLastMousePosition(event)",
						title:"员工 對應 (新視窗)"


					});

					j$('#'+appendId).append(template);
					// j$('.lookupInput').attr(
					// 		{
					// 			onchange:"getElementByIdCS('"+formId+":"+inputId+"').value='';getElementByIdCS('"+formId+":"+inputId+"_mod').value='1';"	
					// 		}
						
					// 	);
					
			}
			function test(){
				j$(".datePicker").attr('display',false);
			}