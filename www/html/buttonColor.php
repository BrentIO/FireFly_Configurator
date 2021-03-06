<?php

    require_once('./api/getConfig.php');
    require_once('common.php');

    //Validate the user is logged in
    checkLogin();

    $pageName = "buttonColor";
    $url = "http://" . $_SERVER['SERVER_ADDR'] . "/api/buttonColor";

?>
<!DOCTYPE html>
<html>
    <head>
        <title>FireFly Configurator - Button Colors</title>
        <link rel="stylesheet" href="bootstrap.min.css">
        <link rel="stylesheet" href="style.css">
        <script src="jquery.min.js"></script>
        <script src="bootstrap.min.js"></script>
        <script src="jquery.toaster.js"></script>
        <script>        

            $(document).ready(function(){

                $.toaster({ settings : {'donotdismiss' : ['danger']  }});

                class buttonColor {
                    id = null;
                    name = null;
                    displayName = null;
                    hexValue = null;
                    brightnessMinimum = null;
                    brightnessMaximum = null;                    
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
                        document.getElementById("operation").innerHTML= "Add New Button Color";

                    }

                    //If editing, retrieve the data from the API
                    if(operation == "edit"){

                        //Set the modal title
                        document.getElementById("operation").innerHTML= "Edit Existing Button Color";

                        $.ajax({

                            beforeSend: function(request) {
                                request.setRequestHeader("x-api-key", "<?php print(getConfig("x-api-key")); ?>");
                            },

                            type: 'GET',
                            url: "<?php print($url);?>" + '/' + button.data('uniqueid'),

                            success: function(data) {

                                //Populate the field elements with the data returned by the API
                                editItemForm.elements["uniqueId"].value = data['id']; 
                                editItemForm.elements["name"].value = data['name']; 
                                editItemForm.elements["displayName"].value = data['displayName'];
                                editItemForm.elements["hexValue"].value = data['hexValue'];
                                editItemForm.elements["brightnessMinimum"].value = data['brightnessMinimum'];      
                                editItemForm.elements["brightnessMaximum"].value = data['brightnessMaximum'];                     
                            },

                            error: function(data){
                                $.toaster({ priority :'danger', title :'Failed', message : data['responseJSON']['error']});
                            },
                        });
                    }
                });


                $(document).on('click', '#buttonSave', function(event){

                    var editItemForm = document.editItem;

                    elementName = editItemForm.elements["name"];

                    var item = new buttonColor();

                    item.id = editItemForm.elements["uniqueId"].value;
                    item.name = editItemForm.elements["name"].value; 
                    item.displayName = editItemForm.elements["displayName"].value;
                    item.hexValue = editItemForm.elements["hexValue"].value;
                    item.brightnessMinimum = editItemForm.elements["brightnessMinimum"].value;      
                    item.brightnessMaximum = editItemForm.elements["brightnessMaximum"].value; 

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
                    var name = button.data('name');
                    var hexValue = button.data('hexvalue');

                    //Clear existing input
                    destroyDeleteData();

                    var deleteItemForm = document.deleteItem;

                    //Set the hidden input value to the ID
                    deleteItemForm.elements["uniqueId"].value = button.data('uniqueid');

                    //Create the prompt text
                    var prompt = "Are you sure you wish to delete $COLOR$? <span style=\"width: 30px; height: 30px; margin:auto; display: inline-block; border: 1px solid gray; vertical-align: middle; border-radius: 2px; background: " + hexValue + "\"></span>";

                    //Build the prompt
                    prompt = prompt.replace("$COLOR$", displayName);
                    prompt = prompt.replace("$COLOR$", name);


                    //Replace any double-spaces
                    prompt = prompt.replace("  ", "");

                    //Set the prompt text on the modal
                    document.getElementById("deletePrompt").innerHTML= prompt;            

                });


                $(document).on('click', '#buttonDelete', function(event){

                    var deleteItemForm = document.deleteItem;

                    var item = new buttonColor;

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
                            $.each(data, function(i){
                                trHTML = "<tr class=\"dynamic\">"
                                            + "<td style=\"text-align:left;\"><span style=\"width: 30px; height: 30px; margin:auto; display: inline-block; border: 1px solid gray; vertical-align: middle; border-radius: 5px; background: " + data[i].hexValue + "\"></span> " + data[i].displayName + "</td>"
                                            + "<td>" + data[i].brightnessMinimum + "</td>"
                                            + "<td>" + data[i].brightnessMaximum + "</td>"
                                            + "<td><button class=\"btn btn-default\" data-toggle=\"modal\" data-target=\"#modalEditItem\" data-backdrop=\"static\" data-operation=\"edit\" data-uniqueid=\"" + data[i].id + "\">Edit</button>"
                                                + "<button class=\"btn btn-danger\" data-toggle=\"modal\" data-target=\"#modalDeleteItem\" data-backdrop=\"static\" data-displayname=\"" + data[i].displayName + "\" data-name=\"" + data[i].name + "\"  data-hexvalue=\"" + data[i].hexValue + "\" id=\"deleteButton\" data-uniqueid=\"" + data[i].id + "\">Delete</button>"
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
            <div id="pageTitle">Button Colors</div><button data-toggle="modal" data-target="#modalEditItem" data-backdrop="static" data-operation="add" class="btn btn-success">Add New</button>
        </div>

        <table class="dataTable" id="dynamicData">
            <tbody>
            <tr>
                <th>Name</th>
                <th>Minimum Brightness</th>
                <th>Maximum Brightness</th>
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
                            <label for="name">Name:</label>
                            <input type="text" id="name"><br><br>
                            <label for="displayName">Display Name:</label>
                            <input type="text" id="displayName"><br><br>
                            <label for="color">Color:</label>
                            <input type="color" id="hexValue"><br><br>
                            <label for="brightnessMinimum">Minimum Brightness:</label>
                            <input type="text" id="brightnessMinimum"><br><br>
                            <label for="brightnessMaximum">Maximum Brightness:</label>
                            <input type="text" id="brightnessMaximum"><br><br>
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