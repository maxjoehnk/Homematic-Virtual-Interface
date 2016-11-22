"use strict";

//
//  HueSceneManager.js
//  Homematic Virtual Interface Plugin
//
//  Created by Thomas Kluge on 20.11.16.
//  Copyright © 2016 kSquare.de. All rights reserved.
//

var HomematicDevice;
	
var HueSceneManager = function(plugin, hueApi) {

    this.mappedScenes = [];
    this.hmDevices = [];
    this.hueApi = hueApi;
    this.log = plugin.log;
    this.server = plugin.server;
    this.bridge = plugin.server.getBridge();

    if (this.bridge == undefined) {
	   throw("HM Layer was not set correctly");
    }
    
	HomematicDevice = plugin.server.homematicDevice;

}

HueSceneManager.prototype.addScene = function(scene) {
	
	this.mappedScenes.push(scene);
}

HueSceneManager.prototype.publish = function() {
  /* what do we do here
  First find out how many RemoteControls we need by dividing / 19
  and then initialize alle the remotes
  */
  
  var i = 1;
  var cnt = 0;
  var that = this;
  
  this.addHMRemote("HUESCENE00"  + cnt);
  
  this.mappedScenes.map(function(scene){
    scene["hmchannel"] = "HUESCENE00"  + cnt + ":"+i;
    
    i=i+1;
    if (i>19) {
	   i=1;
	   cnt = cnt + 1; 
	   that.addHMRemote("HUESCENE00"  + cnt);
    }	  
  });
}

HueSceneManager.prototype.addHMRemote = function(remoteName) {
	var hmDevice = new HomematicDevice("HM-RC-19", remoteName);
    this.hmDevices.push(hmDevice);
    this.bridge.addDevice(hmDevice);
    var that = this;
    
    hmDevice.on('device_channel_value_change', function(parameter){
			
		var newValue = parameter.newValue;
		var channel = hmDevice.getChannel(parameter.channel);
		if (parameter.name == "PRESS_SHORT") {
			that.mappedScenes.map(function (scene){
				if (scene["hmchannel"] == channel.adress) {
					that.log.debug("Scene found " + scene["name"] +  " will run that");
					that.hueApi.activateScene(scene["id"],function(err, result) {});
				}
			});
	    }
	});
}

HueSceneManager.prototype.getMappedScenes = function() {
  return this.mappedScenes;
}

module.exports = {
	HueSceneManager : HueSceneManager
}