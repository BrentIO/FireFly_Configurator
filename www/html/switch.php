<?php

    require_once('./api/getConfig.php');
    require_once('common.php');

    //Validate the user is logged in
    checkLogin();

    $pageName = "switch";
    $url = "http://" . $_SERVER['SERVER_ADDR'] . "/api/switch";
    $controllerURL = "http://" . $_SERVER['SERVER_ADDR'] . "/api/controller";
    $firmwareURL = "http://" . $_SERVER['SERVER_ADDR'] . "/api/firmware";

?>
<!DOCTYPE html>
<html>
    <head>
        <title>FireFly Configurator - Switches</title>
        <link rel="stylesheet" href="bootstrap.min.css">
        <link rel="stylesheet" href="style.css">
        <script src="jquery.min.js"></script>
        <script src="bootstrap.min.js"></script>
        <script src="jquery.toaster.js"></script>
        <script>

            function controllerChanged(){
                var editItemForm = document.editItem;

                if(editItemForm.elements["controllerId"].value == editItemForm.elements["controllerId"].getAttribute("data-default")){
                    //The current value was re-selected
                    editItemForm.elements["portAutoAssign"].checked = false;
                    editItemForm.elements["portAutoAssign"].disabled = false;
                    setPortHidden(false);
                }else{
                    //A different value was selected, block the user from manually assigning the pin and port
                    editItemForm.elements["portAutoAssign"].checked = true;
                    editItemForm.elements["portAutoAssign"].disabled = true;
                    setPortHidden(true);

                }       
            }

            function setPortHidden(value){
                var editItemForm = document.editItem;
                editItemForm.elements["controllerPort"].hidden = value;

                if(value == true){

                    document.getElementById('controllerPortLabel').style.visibility = 'hidden';

                }else{
                    document.getElementById('controllerPortLabel').style.visibility = 'visible';
                }
                            
            }

            function setMQTTUsernameHidden(value){
                var editItemForm = document.editItem;
                editItemForm.elements["mqttUsername"].hidden = value;

                if(value == true){

                    document.getElementById('mqttUsernameLabel').style.visibility = 'hidden';

                }else{
                    document.getElementById('mqttUsernameLabel').style.visibility = 'visible';
                }
                
            }

            function setMQTTPasswordHidden(value){
                
                var editItemForm = document.editItem;
                editItemForm.elements["mqttPassword"].hidden = value;
                
                if(value == true){

                    document.getElementById('mqttPasswordLabel').style.visibility = 'hidden';

                }else{
                    document.getElementById('mqttPasswordLabel').style.visibility = 'visible';
                }
            }



            $(document).ready(function(){

                $.toaster({ settings : {'donotdismiss' : ['danger']  }});

                class switchClass {
                    id = null;
                    name = null;
                    displayName = null;
                    macAddress = null;
                    firmwareId = null;
                    controllerId = null;
                    controllerPort = null;
                    hwVersion = null;
                    mqttUsername = null;
                    mqttPassword = null;
                }
            
                //Load the data on page load
                loadTableData();


                $('#modalEditItem').on('show.bs.modal', function (event) {
                    /*************************************************
                    **  Handle the edit item modal being requested  **
                    *************************************************/

                    //Retrieve the data associated to the button press event
                    var button = $(event.relatedTarget);
                    var operation = button.data('operation');

                    //Clear existing input
                    destroyEditData();

                    var editItemForm = document.editItem;

                    if(operation == "add"){

                        //Set the modal title
                        document.getElementById("operation").innerHTML= "Add New Switch";

                        $.when(

                            //Get the list of controllers
                            $.ajax({
                                beforeSend: function(request) {
                                    request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                                },
                                url: "<?php print($controllerURL);?>",

                                success: function(data) {

                                    //Add the list of controllers to the drop-down
                                    $.each(data, function(i){
                                        optionHTML = "<option value=\"" + data[i].id + "\">(" + data[i].name + ") " + data[i].displayName + "</option>";
                                    
                                        $('#controllerId').append(optionHTML);
                                    });

                                },

                                fail: function(data){
                                    $.toaster({ priority :'danger', title :'Getting Controllers Failed', message : data['responseJSON']['error']});
                                }
                            }),

                            //Get the list of firmware
                            $.ajax({
                                beforeSend: function(request) {
                                    request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                                },
                                url: "<?php print($firmwareURL);?>",

                                success: function(data) {
                                    
                                    //Add the list of device-appropriate firmware to the drop-down
                                    $.each(data, function(i){

                                        if(data[i].deviceType == "SWITCH"){

                                            optionHTML = "<option value=\"" + data[i].id + "\">" + data[i].version + "</option>";
                                            $('#firmwareId').append(optionHTML);

                                        };
                                    });
                                },

                                fail: function(data){
                                    $.toaster({ priority :'danger', title :'Getting Firmware Failed', message : data['responseJSON']['error']});
                                }
                            })

                        ).then(function(){
                            editItemForm.elements["controllerId"].setAttribute("data-default", null);
                            editItemForm.elements["portAutoAssign"].checked = true;
                            editItemForm.elements["portAutoAssign"].disabled = true;
                            setPortHidden(true);
                            editItemForm.elements["mqttUsernameDefault"].checked = true;
                            setMQTTUsernameHidden(true);
                            editItemForm.elements["mqttPasswordDefault"].checked = true;
                            setMQTTPasswordHidden(true);
                            editItemForm.elements["hwVersion"].value = "2";

                        });
                    }

                    //If editing, retrieve the data from the API
                    if(operation == "edit"){

                        //Set the modal title
                        document.getElementById("operation").innerHTML= "Edit Existing Switch";

                        switchData = null;

                        $.when(

                            //Get the data about this ID
                            $.ajax({

                                beforeSend: function(request) {
                                    request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                                },

                                type: 'GET',
                                url: "<?php print($url);?>" + '/' + button.data('uniqueid'),

                                success: function(data) {

                                    switchData = data;
                                },

                                error: function(data){
                                    $.toaster({ priority :'danger', title :'Failed', message : data['responseJSON']['error']});
                                },
                            }),

                            //Get the list of controllers
                            $.ajax({
                                beforeSend: function(request) {
                                    request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                                },
                                url: "<?php print($controllerURL);?>",

                                success: function(data) {

                                    //Add the list of controllers to the drop-down
                                    $.each(data, function(i){
                                        optionHTML = "<option value=\"" + data[i].id + "\">(" + data[i].name + ") " + data[i].displayName + "</option>";
                                    
                                        $('#controllerId').append(optionHTML);
                                    });

                                },

                                fail: function(data){
                                    $.toaster({ priority :'danger', title :'Getting Controllers Failed', message : data['responseJSON']['error']});
                                }
                            }),

                            //Get the list of firmware
                            $.ajax({
                                beforeSend: function(request) {
                                    request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                                },
                                url: "<?php print($firmwareURL);?>",

                                success: function(data) {
                                    
                                    //Add the list of device-appropriate firmware to the drop-down
                                    $.each(data, function(i){

                                        if(data[i].deviceType == "SWITCH"){

                                            optionHTML = "<option value=\"" + data[i].id + "\">" + data[i].version + "</option>";
                                            $('#firmwareId').append(optionHTML);

                                        };
                                    });
                                },

                                fail: function(data){
                                    $.toaster({ priority :'danger', title :'Getting Firmware Failed', message : data['responseJSON']['error']});
                                }
                            })

                        ).then(function(){

                            //Populate the field elements with the data returned by the API
                            editItemForm.elements["uniqueId"].value = switchData['id']; 
                            editItemForm.elements["name"].value = switchData['name']; 
                            editItemForm.elements["displayName"].value = switchData['displayName'];
                            editItemForm.elements["macAddress"].value = switchData['macAddress'];
                            editItemForm.elements["firmwareId"].value = switchData['firmwareId'];
                            editItemForm.elements["controllerId"].value = switchData['controllerId'];
                            editItemForm.elements["controllerId"].setAttribute("data-default", switchData['controllerId']);
                            editItemForm.elements["controllerPort"].value = switchData['controllerPort'];
                            editItemForm.elements["hwVersion"].value = switchData['hwVersion'];
                            editItemForm.elements["mqttUsername"].value = switchData['mqttUsername'];
                            editItemForm.elements["mqttPassword"].value = switchData['mqttPassword'];
                            editItemForm.elements["hwVersion"].value = "2";

                            editItemForm.elements["mqttUsernameDefault"].checked = switchData['mqttUsernameDefault'];
                            setMQTTUsernameHidden(switchData['mqttUsernameDefault']);
                            editItemForm.elements["mqttUsername"].value = switchData['mqttUsername'];

                            editItemForm.elements["mqttPasswordDefault"].checked = switchData['mqttPasswordDefault'];
                            setMQTTPasswordHidden(switchData['mqttPasswordDefault']);
                            editItemForm.elements["mqttPassword"].value = switchData['mqttPassword'];
                        });
                    }
                });


                $(document).on('click', '#buttonSave', function(event){

                    var editItemForm = document.editItem;

                    elementName = editItemForm.elements["name"];

                    var item = new switchClass();

                    item.id = editItemForm.elements["uniqueId"].value;
                    item.name = editItemForm.elements["name"].value;
                    item.displayName = editItemForm.elements["displayName"].value;
                    item.macAddress = editItemForm.elements["macAddress"].value;
                    item.firmwareId = editItemForm.elements["firmwareId"].value;
                    item.controllerId = editItemForm.elements["controllerId"].value;
                    item.hwVersion = editItemForm.elements["hwVersion"].value;

                    if(editItemForm.elements["portAutoAssign"].checked){
                        item.controllerPort = null;
                    }else{
                        item.controllerPort = editItemForm.elements["controllerPort"].value;
                    }

                    if(editItemForm.elements["mqttUsernameDefault"].checked){
                        item.mqttUsername = null;
                    }else{
                        item.mqttUsername = editItemForm.elements["mqttUsername"].value;
                    }

                    if(editItemForm.elements["mqttPasswordDefault"].checked){
                        item.mqttPassword = null;
                    }else{
                        item.mqttPassword = editItemForm.elements["mqttPassword"].value;
                    } 

                    if(item.id == ""){
                        item.id = null;
                    }

                    //Send the item to the API
                    editItem(item);

                    //Hide the modal
                    $("#modalEditItem").modal("hide");

                });


                $('#modalDeleteItem').on('show.bs.modal', function (event) {
                    /*************************************************
                    **  Handle the delete item modal being requested**
                    *************************************************/

                    //Retrieve the data associated to the button press event
                    var button = $(event.relatedTarget);
                    var displayName = button.data('displayname');

                    //Clear existing input
                    destroyDeleteData();

                    var deleteItemForm = document.deleteItem;

                    //Set the hidden input value to the ID
                    deleteItemForm.elements["uniqueId"].value = button.data('uniqueid');

                    //Create the prompt text
                    var prompt = "Are you sure you wish to delete $DISPLAYNAME$?";

                    //Build the prompt
                    prompt = prompt.replace("$DISPLAYNAME$", displayName);

                    //Replace any double-spaces
                    prompt = prompt.replace("  ", "");

                    //Set the prompt text on the modal
                    document.getElementById("deletePrompt").innerHTML= prompt;            

                });


                $(document).on('click', '#buttonDelete', function(event){

                    var deleteItemForm = document.deleteItem;

                    var item = new switchClass;

                    item.id = deleteItemForm.elements["uniqueId"].value;

                    //Delete the item
                    deleteItem(item);

                    //Hide the modal
                    $("#modalDeleteItem").modal("hide");

                });


                function destroyEditData(){
                    /*************************************************
                    **  Destroys the data on the edit form          **
                    *************************************************/

                    //Get the form inputs
                    var editItemForm = document.editItem;

                    //For each input
                    for(var i = 0; i < editItemForm.length; i++){
                        
                        //Clear the data
                        editItemForm[i].value = null;
                    }

                    //Delete the controller drop-down options
                    while(document.getElementById("controllerId").length > 0){
                        document.getElementById("controllerId").remove(0);
                    }

                    while(document.getElementById("firmwareId").length > 0){
                        document.getElementById("firmwareId").remove(0);
                    }

                    //Re-enabled the form elements
                    editItemForm.elements["portAutoAssign"].checked = false;
                    editItemForm.elements["portAutoAssign"].disabled = false;
                    setPortHidden(false);

                };


                function destroyDeleteData(){
                    /*************************************************
                    **  Destroys the data on the delete form          **
                    *************************************************/

                    //Get the form inputs
                    var deleteItemForm = document.deleteItem;

                    //For each input
                    for(var i = 0; i < deleteItemForm.length; i++){
                        
                        //Clear the data
                        deleteItemForm[i].value = null;
                    }

                };


                function editItem(item){
                    /*************************************************
                    **  Adds new or edits existing entries based on **
                    **      the ID passed in                        **
                    *************************************************/

                    if(item.id == null){
                        var method="POST";
                        var url = "<?php print($url);?>";
                    }else{
                        var method="PATCH";
                        var url = "<?php print($url);?>" + '/' + item.id;
                    }

                    $.ajax({

                        beforeSend: function(request) {
                            request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                        },
                        data: JSON.stringify(item),
                        type: method,
                        url: url,

                        success: function(data) {
                            $.toaster({ priority :'success', title :'Edit', message : 'Successful'});
                        },

                        error: function(data){
                            $.toaster({ priority :'danger', title :'Failed', message : data['responseJSON']['error']});
                        },

                        complete: function(){
                            loadTableData();
                        }

                    });

                }


                function deleteItem(item){
                    /*************************************************
                    **  Loads the specified ID from the database    **
                    *************************************************/

                    $.ajax({

                        beforeSend: function(request) {
                            request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                        },
                        type: 'DELETE',
                        url: "<?php print($url);?>" + '/' + item.id,

                        success: function(data) {
                            $.toaster({ priority :'success', title :'Deletion', message : 'Successful'});
                        },

                        error: function(data){
                            $.toaster({ priority :'danger', title :'Failed', message : data['responseJSON']['error']});
                        },

                        complete: function(){
                            loadTableData();                    
                        }

                    });
                }


                function loadTableData(){
                    /*************************************************
                    **  Loads the data from the API into the data   **
                    **      table for viewing and editing           **
                    *************************************************/

                    //Delete the existing contents of the table
                    $('.dynamic').remove();

                    //Load the table
                    $.ajax({
                        beforeSend: function(request) {
                            request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                        },
                        url: "<?php print($url);?>",

                        success: function(data) {

                            data = data.sort((a, b) => (a.name > b.name) ? 1 : -1);

                            $.each(data, function(i){
                                trHTML = "<tr class=\"dynamic\">"
                                            + "<td>" + data[i].name + "</td>"
                                            + "<td>" + data[i].displayName + "</td>"
                                            + "<td>" + data[i].macAddress + "</td>"
                                            + "<td>" + data[i].firmwareVersion + "</td>"
                                            + "<td>" + data[i].controllerDisplayName + " (port " + data[i].controllerPort + ")</td>"
                                            + "<td><button class=\"btn btn-default\" data-toggle=\"modal\" data-target=\"#modalEditItem\" data-backdrop=\"static\" data-operation=\"edit\" data-uniqueid=\"" + data[i].id + "\">Edit</button>"
                                                + "<button class=\"btn btn-danger\" data-toggle=\"modal\" data-target=\"#modalDeleteItem\" data-backdrop=\"static\" data-displayname=\"" + data[i].displayName + "\" id=\"deleteButton\" data-uniqueid=\"" + data[i].id + "\">Delete</button>"
                                            + "</td>"
                                        +"</tr>"
                                $('#dynamicData').append(trHTML);
                            });
                        },

                        fail: function(data){
                            $.toaster({ priority :'danger', title :'Failed', message : data['responseJSON']['error']});
                        }
                    });
                };
            
            });

        </script>
    </head>
    <body>

<?php include "menu.php"?>
        
        <div class="content">
        <div id="pageName">
            <div id="pageTitle">Switches</div><button data-toggle="modal" data-target="#modalEditItem" data-backdrop="static" data-operation="add" class="btn btn-success">Add New</button>
        </div>

        <table class="dataTable" id="dynamicData">
            <tbody>
            <tr>
                <th>Short Name</th>
                <th>Display Name</th>
                <th>MAC Address</th>
                <th>Firmware Version</th>
                <th>Controller</th>
                <th>Operations</th>
            </tr>
            </tbody>
        </table>


        <!-- Edit Item Modal -->
        <div class="modal fade" id="modalEditItem" role="dialog">
            <div class="modal-dialog">

                <!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title"><div id="operation"></div></h4>
                    </div>
                    <div class="modal-body" name="form">
                        <form name="editItem">
                        <input type="hidden" id="uniqueId">
                            <label for="name">Short Name:</label>
                            <input type="text" id="name"><br><br>
                            <label for="displayName">Display Name:</label>
                            <input type="text" id="displayName"><br><br>
                            <label for="macAddress">MAC Address:</label>
                            <input type="text" id="macAddress"><br><br>
                            <label for="controllerId">Controller:</label>
                            <select id="controllerId" oninput="controllerChanged()"></select><br><br>
                            <label for="portAutoAssign">Auto-Assign Port</label>
                            <input type="checkbox" id="portAutoAssign" onchange="setPortHidden(this.checked)">
                            <label for="controllerPort" id="controllerPortLabel">Port:</label>
                            <input type="text" id="controllerPort" size="4" readonly><br><br>
                            <label for="firmwareId">Firmware:</label>
                            <select id="firmwareId"></select><br><br>
                            <label for="mqttUsernameDefault">Use Default MQTT Username</label>
                            <input type="checkbox" id="mqttUsernameDefault" onchange="setMQTTUsernameHidden(this.checked)"><br><br>
                            <label for="mqttUsername" id="mqttUsernameLabel">MQTT Username:</label>
                            <input type="text" id="mqttUsername" size=50><br><br>
                            <label for="mqttPasswordDefault">Use Default MQTT Password</label>
                            <input type="checkbox" id="mqttPasswordDefault" onchange="setMQTTPasswordHidden(this.checked)"><br><br>
                            <label for="mqttPassword" id="mqttPasswordLabel">MQTT Password:</label>
                            <input type="text" id="mqttPassword" size=50><br><br>
                            <label for="hwVersion">Hardware:</label>
                            <select id="hwVersion">
                                <option value="2">Version 2</option>
                            </select>
                           
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="buttonSave">Save</button>
                    </div>
                </div>
            </div>
        </div>


        <!-- Delete Item Modal -->
        <div class="modal fade" id="modalDeleteItem" role="dialog">
            <div class="modal-dialog">

                <!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Delete</h4>
                    </div>
                    <form name="deleteItem">
                        <input type="hidden" id="uniqueId">
                    </form>
                    <div class="modal-body"><div id="deletePrompt"></div></div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger" id="buttonDelete">Delete</button>
                    </div>
                </div>
            </div>
        </div>

        </div>
    </body>
</html>