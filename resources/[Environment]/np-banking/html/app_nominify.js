let ValidAccounts = {};
let CurrentTransactions = [];
let curAccount = "";
let folder_name = GetParentResourceName()

function UpdateAccount(divId, bal)
{
    $("#" + divId + "_Balance").html("$" + bal.toLocaleString());
}

let GlobalSteamID = "";

function ResetModals(type, sSteamID)
{
    
    // Amounts
    $("#depositAmount").val(0);
    $("#withdrawAmount").val(0);
    $("#transferAmount").val(0);
    // Notes
    $("#depositNote").val("");
    $("#withdrawNote").val("");
    $("#transferNote").val("");
    // Transfer ID
    $("#transferID").val(1);

    curAccount = type;

    if (sSteamID && sSteamID !== "undefined")
        GlobalSteamID = sSteamID;
}

var lang = [];
lang["personal"] = "Personal Account";
lang["business"] = "Buisness Account";
lang["friend"] = "Shared Account"
lang["deposit"] = "Deposit";
lang["withdraw"] = "Withdrawal";
lang["transfer"] = "Transfer";

var relang = [];
relang["Personal Account"] = "personal";
relang["Buisness Account"] = "business";
relang["Shared Account"] = "friend";

function AddAccount(account_name, account_type, bal, xPlayer_Name, steamID)
{
    let temp_name = account_name.replace(/"|'/g,'');
    let temp_Name = account_name.replace(/\s+/g, '');
    
    let transferAcc = relang[account_type];
    
    if (ValidAccounts[temp_Name])
        return UpdateAccount(temp_Name, bal);

    $("#Player_Accounts").append("<div id='"+temp_Name+"'\
        <div class='card bg-secondary'>\
            <div class='account'>\
                <h5 class='card-title note'>" + account_name + (relang[account_type] === "personal" && " <i OnClick='EditAccount(\"" + transferAcc + "\")' class='justify-content-end right fa fa-cog account_settings'></i>" || "") + "</h5>\
                <p class='card-subtitle note'>" + account_type + "</p>\
\
                <div class='row'>\
                    <div class='col'>\
                        <p class='card-subtitle mb-2'>" + xPlayer_Name + "</p>\
                    </div>\
\
                    <div class='col mb-2'>\
\
                        <div class='d-flex justify-content-end'>\
                            <h5 id='" + temp_Name + "_Balance' class='odometer'>$" + bal.toLocaleString() + "</h5>\
                        </div>\
                        <div class='d-flex justify-content-end mt-1 mb-1'>\
                            <p class='card-subtitle'>Available Balance</p>\
                            \
                        </div>\
                    </div>\
                </div>\
\
                <hr>\
                <div class='d-flex justify-content-between'>\
                    <button type='button' class='btn btn-light mb-2 text-muted deposit' data-toggle='modal' data-target='#DepositModal' onClick='ResetModals(\"" + transferAcc + "\", \"" + steamID + "\")'>DEPOSIT</button>\
                    <button type='button' class='btn btn-light mb-2 text-muted withdraw' data-toggle='modal' data-target='#WithdrawModal' onClick='ResetModals(\"" + transferAcc + "\", \"" + steamID + "\")'>WITHDRAW</button>\
                    <button type='button' class='btn btn-light mb-2 text-muted transfer' data-toggle='modal' data-target='#TransferModal' onClick='ResetModals(\"" + transferAcc + "\", \"" + steamID + "\")'>TRANSFER</button>\
                </div>\
            </div>\
    </div><br/></div>");

    ValidAccounts[temp_Name] = transferAcc;
}

function timeSince(date) {

    var seconds = Math.floor((new Date() - date) / 1000);
  
    var interval = seconds / 31536000;
  
    if (interval > 1) {
      return Math.floor(interval) + " years";
    }
    interval = seconds / 2592000;
    if (interval > 1) {
      return Math.floor(interval) + " months";
    }
    interval = seconds / 86400;
    if (interval > 1) {
      return Math.floor(interval) + " days";
    }
    interval = seconds / 3600;
    if (interval > 1) {
      return Math.floor(interval) + " hours";
    }
    interval = seconds / 60;
    if (interval > 1) {
      return Math.floor(interval) + " minutes";
    }
    return Math.floor(seconds) + " seconds";
  }

  function htmlEncode(source) {
    return $("<div>").text(source).html();
  }

function addNote(note)
{
    return "<div>\
        <hr>\
            <h6 class='note'>Note</h6>\
            <p class='note'>" + htmlEncode(note) + "</p>\
        </hr>\
    </div>"
}
function AddTransaction(trans_id, account, amount, time, note, why, receiver, plName)
{
    if (CurrentTransactions[trans_id])
        return;

    let ColStr = (amount.toString().charAt(0) === "-" && "expense" || "addition");

    let curTime = new Date();
    let newDate = new Date(time);

    let TimeSince = timeSince(newDate);

    let str = (amount.toString().charAt(0) === "-" && "-$" + parseInt(amount.toString().substring(1, amount.length)).toLocaleString() || "+$" + amount.toLocaleString())
    $("#Transaction_Row").prepend("\
        <div class='card bg-secondary mb-2'>\
            <div class='card-body'>\
                <div class='col'>\
                <!-- Header -->\
                <div class='row game-header'>\
                    <div class='col'>\
                        <p class='header-title'> " + lang[account] + "</p>\
                    </div>\
                    <div class='col d-flex justify-content-end'>\
                        <p class='header-title'><span class='badge bg-primary'>Bank Transfer</span> <> <span class='badge bg-dark'>" + lang[why] + "</span></p>\
                    </div>\
                    <hr/>\
                    <div class='col-2'>\
                        <b class='" + ColStr + "'> " + str + "</b>\
                    </div>\
                    <div class='col-5'>\
                        " + (receiver === "N/A" && plName || receiver) + "\
                    </div>\
                        <div class='col d-flex justify-content-end'>\
                            <div>\
                                <p class='note'>" + TimeSince + " ago</p>\
                                <p class='note'> " + plName + "</p>\
                            </div>\
                        </div>\
                    " + (note != "" && addNote(note) || "") + "\
                    </div>\
                </div>\
            </div>\
        </div>\
    ")

    CurrentTransactions[trans_id] = true;
}


function OpenATM(data, friends, transactions, name)
{
    if (data && data !== null)
    {
        let tbl = JSON.parse(data);
        for (var i = 0; i < tbl.length; i++)
        {
            let tTbl = tbl[i];
            AddAccount((tTbl.type === "business" && tTbl.name || "Personal Account"), (lang[tTbl.type] && lang[tTbl.type] || tTbl.type), tTbl.amount, name);
        }
    }

    if (friends && friends !== null)
    {
        friends = JSON.parse(friends);
        for (var i = 0; i < friends.length; i++)
        {
            let v = friends[i];
            AddAccount(v.owner, "Shared Account", v.amount, name, v.id);
        }
    }

    if (transactions && transactions !== null)
    {
        transactions = JSON.parse(transactions);
        for (var i = 0; i < transactions.length; i++)
        {
            let tTbl = transactions[i];

            AddTransaction(tTbl.trans_id, tTbl.account, tTbl.amount, tTbl.date, tTbl.message, tTbl.trans_type, tTbl.receiver || "Unknown", name);
        }
    }

    $('#bankui').fadeTo(10, 1.0)
}

function confirmDeposit()
{
    let amount = $("#depositAmount").val();

    if(!amount || amount <= 0)
        return;
    
    let note = $("#depositNote").val();
    $("#DepositModal").modal().hide();
    $('.modal-backdrop').remove()

    $.post("http://" + folder_name + "/DepositCash", JSON.stringify({
        account: curAccount,
        amount: amount,
        note: note,
        steamid: GlobalSteamID
    }));
}

function confirmWithdraw()
{
    let amount = $("#withdrawAmount").val();

    if(!amount || amount <= 0)
        return;
    
    let note = $("#withdrawNote").val();
    $(".modal").hide();
    $('.modal-backdrop').remove() // removes the grey overlay.

    $.post("http://" + folder_name + "/WithdrawCash", JSON.stringify({
        account: curAccount,
        amount: amount,
        note: note,
        steamid: GlobalSteamID
    })); 
}

function confirmTransfer()
{
    //if (!curAccount)
        //curAccount = "personal";

    let amount = $("#transferAmount").val();
    let tTarget = $("#transferID").val();
    if(!amount || amount <= 0)
        return;
    
    let note = $("#transferNote").val();
    $("#TransferModal").modal().hide();
    $('.modal-backdrop').remove() // removes the grey overlay.

    $.post("http://" + folder_name + "/TransferCash", JSON.stringify({
        account: curAccount,
        amount: amount,
        target: tTarget,
        note: note,
        steamid: GlobalSteamID
    }));
}

function confirmRemove(identifier, name)
{
    if ($("#editAccountModal").is(':visible'))
        $("#editAccountModal").modal('toggle');

    $.post("http://" + folder_name + "/RemoveAccess", JSON.stringify({
        target: identifier,
        player: name
    }));
}

function EditAccount(clss)
{
    if (clss != "personal")
        return TropixNotification("Company accounts have no settings yet, sorry!", "error")

    $.post("http://" + folder_name + "/EditAccount", JSON.stringify({}))
}

function TropixNotification(msg, typ)
{
    $("#notifaction_type").text(typ == "error" && "Error!" || "Success!")
    $("#notification_msg").text(msg);
    $("#notificationModal").modal('toggle');
}

let Listeners = [];

Listeners["notification"] = function(data)
{
    $("#notifaction_type").text(data.msg_type && data.msg_type == "error" && "Error!" || "Success!")
    $("#notification_msg").text(data.message);
    $("#notificationModal").modal('toggle');
}

Listeners["OpenUI"] = function(data)
{
    let name = data.name;
    OpenATM(data.accounts, data.friends, data.transactions, name);
}

Listeners["edit_account"] = function(data)
{

    if (data) {
        let auths = JSON.parse(data.auths);
        $("#who_has_access").html("");
        
        for (var i = 0; i < auths.length; i++)
        {
            let v = auths[i];

            let curTime = new Date();
            let newDate = new Date(v.date_added);
        
            let TimeSince = timeSince(newDate);
            $("#who_has_access").append("<tr>\
            <td>" + v.target_name + "</td>\
            <td>" + TimeSince + "(s) ago</td>\
            <td><button class='btn btn-danger btn-sm' onclick='confirmRemove(\"" + v.target_identifier + "\", \"" + v.target_name + "\")'>Remove</button></td>\
            ");
        }
    } else {
        TropixNotification("Nobody has access to your bank!", "error");
        return;
    }

    $("#editAccountModal").modal('toggle');
}

Listeners["refresh_accounts"] = function() {

    for (var key in ValidAccounts) {

       let data = ValidAccounts[key];

        if (data && data === "business" || data === "friend")
        {
            ValidAccounts[key] = null;
            $("#" + key).remove();
            $('#Player_Accounts').find('br:last-child').remove();
        }
    }
}

function closeNotification(br)
{
    if (br)
        return $("#editAccountModal").modal('toggle');

    $("#notificationModal").modal('toggle');
}

$(function()
{
    window.addEventListener('message', event => {
        let type = event.data.type;

        if (Listeners[type])
            Listeners[type](event.data);
    })

    document.onkeyup = function(data){
        if (data.which == 27){
            if ($("#editAccountModal").is(':visible'))
                $("#editAccountModal").modal('toggle');

            if ($("#notificationModal").is(':visible'))
                $("#notificationModal").modal('toggle');
                
            if ($("#DepositModal").is(':visible'))
                $("#DepositModal").modal().hide();

            if ($("#WithdrawModal").is(':visible'))
                $("#WithdrawModal").modal().hide();

            if ($("#TransferModal").is(':visible'))
                $("#TransferModal").modal().hide();

            $('.modal-backdrop').remove()

            $("#bankui").fadeTo(10, 0, () => $.post("http://" + folder_name + "/CloseATM", JSON.stringify({})));
        }
    }

})

function CloseUIPls()
{
    if ($("#editAccountModal").is(':visible'))
        $("#editAccountModal").modal('toggle');
    if ($("#notificationModal").is(':visible'))
        $("#notificationModal").modal('toggle');

    $("#bankui").fadeTo(10, 0, () => $.post("http://" + folder_name + "/CloseATM", JSON.stringify({})));
}


$(function()
{
    $("bankui").hide();
})