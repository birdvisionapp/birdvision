function calculateAndDisplayProductPenetration(){
	var $myFuelMeter;
	var unusedCodes = $(".unused-codes").text();
    var usedCodes = $(".used-codes").text();
    var penetration = ((usedCodes/unusedCodes) * 100).toFixed(2);
    $myFuelMeter = $("div#product-penetration-gauge").dynameter({
        width: 200,
        label: 'penetration',
        value: penetration,
        min: 0.0,
        max: 100.0,
        unit: '',
        regions: {
          0: 'normal',
          40: 'warn',
          70: 'error'
        }
      });
}



function tractionArrayKey(testSearch) {
	var commArray = [];
	var dateFormat;
	var test = JSON.parse(testSearch);
	
	if (test[0] == null) {
		return 0;
	}
	
	var firstData = test[0]['date'].toString().length;

	if (firstData == 4) {
		for (var i = 0; i < test.length; i++) {
			dateFormat = test[i]["date"];
			var value = JSON.stringify(dateFormat);
			var value = value.replace(/"/g, "");
			commArray[i] = value;
		}
		return commArray;
	}
	if (firstData != 4 && test[0]['date'][1] == 0) {
		for (var i = 0; i < test.length; i++) {
			dateFormat = test[i]["date"];
			var value = JSON.stringify(dateFormat);
			var value = value.replace(/"/g, "");
			commArray[i] = value;
		}
		return commArray;
	}
	if (test[0]['date'][1] != 0) {
		for (var i = 0; i < test.length; i++) {
			dateFormat = test[i]["date"][0] + ',' + test[i]["date"][1];
			var value = JSON.stringify(dateFormat);
			var value = value.replace(/"/g, "");
			commArray[i] = value;
		}
		return commArray;
	}
}

function tractionArrayValue(testSearch) {
	var commArray = [];
	var dateFormat;
	var test = JSON.parse(testSearch);
	for (var i = 0; i < test.length; i++) {
		dateFormat = test[i]["user_count"];
		var value = JSON.stringify(dateFormat);
		var value = value.replace(/"/g, "");
		commArray.push([parseFloat(value)]);
	}
	return commArray;
}

function communityTraction() {

	var commulativeUser = $(".commulative-count").text();
	var nonCommulativeUser = $(".non-commulative-count").text();
	if (commulativeUser.length == 0 && nonCommulativeUser.length == 0 ) {
			return 0;		
		}

	var xaxisData = tractionArrayKey(commulativeUser);

	$('#container').highcharts({
		title : {
			text : '',
			// x : -20 //center
		},
		 subtitle: {
            text: '',
            // x: -20
        },
		xAxis : {
			title: {
                text: 'Dates'
            },
			categories : xaxisData
		},
		yAxis : {
			title: {
                text: 'Counts'
            },
			plotLines : [{
				value : 0,
				width : 1,
				color : '#808080'
			}]
		},
		legend : {
			layout : 'vertical',
			align : 'right',
			verticalAlign : 'middle',
			borderWidth : 0
		},
		series : [{
			name : 'Cumulative Community Count',
			data : tractionArrayValue(commulativeUser)
		}, {
			name : 'Non-Cumulative Community Count',
			data : tractionArrayValue(nonCommulativeUser)
		}]
	});
};


$(document).ready(function () {
	 calculateAndDisplayProductPenetration();
	 communityTraction();

	//$(".widget-postion-inner").mouseover(function(){
	  //  $('.remove-widget').show(); 
	//});
	
	//$(".widget-postion-inner").mouseout(function(){
	  //  $('.remove-widget').hide(); 
	//});
	
	$("#edit-widgets").click(function(){
	   $('.remove-widget-button').show(); 
	});
});