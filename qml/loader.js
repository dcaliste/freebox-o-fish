/*
 * loader.js
 * Copyright (C) Damien Caliste 2014 <dcaliste@free.fr>
 *
 * freebox-o-fish is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 */

function load(method, url, sendObj, respFunc) {
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            console.log("Headers -->");
            console.log(doc.getAllResponseHeaders ());
            console.log("Last modified -->");
            console.log(doc.getResponseHeader ("Last-Modified"));

        } else if (doc.readyState == XMLHttpRequest.DONE) {
            console.log(doc.status + " " + doc.statusText);
            //console.log(doc.responseText);
            if (doc.status == 200 && respFunc) {
                respFunc(eval("(" + doc.responseText + ")"));
            }
        }
    }

    console.log(method + url);
    doc.open(method, url);
    if (session_token.length > 0)
        doc.setRequestHeader("X-Fbx-App-Auth", session_token);
    if (sendObj)
        doc.send(sendObj);
    else
        doc.send();
    console.log(sendObj);
}

function getDB() {
    var db = LocalStorage.openDatabaseSync("box-o-fish", "0.1",
                                           "Local storage for Box-o-Fish", 10000);
    return db;
}

function getAppToken() {
    // Variables coming from QML
    app_token = "";
    track_id  = 0;
    var db = getDB();
    db.transaction(function(tx) {
        // Create the database if it doesn't already exist
        tx.executeSql('CREATE TABLE IF NOT EXISTS Freebox(id TEXT, app_token TEXT, track_id INT)');
        var rs = tx.executeSql('SELECT app_token, track_id FROM Freebox WHERE id = ?', [freebox_id, ]);
        if (rs.rows.length > 0) {
            app_token = rs.rows.item(0).app_token;
            track_id  = rs.rows.item(0).track_id;
        }
    });
}

function setAppToken(vals) {
    var db = getDB();
    console.log("Set app_token" + vals)
    db.transaction(function(tx) {
        // Create the database if it doesn't already exist
        tx.executeSql('CREATE TABLE IF NOT EXISTS Freebox(id TEXT, app_token TEXT, track_id INT)');
        tx.executeSql('CREATE UNIQUE INDEX IF NOT EXISTS id_index ON Freebox(id)');
        var rs = tx.executeSql('INSERT INTO Freebox VALUES (?, ?, ?)', [freebox_id, vals["result"]["app_token"], vals["result"]["track_id"]]);
    });
    getAppTokenStatus();
}
function authorizeAppToken() {
    var obj = '{"app_id": "fr.freebox.box-o-fish", "app_name": "Box-o-Fish", "app_version": "0.1", "device_name": "Jolla"}';
    console.log("Post authorization request");
    load("POST", url + "/api/v1/login/authorize", obj, setAppToken);
}

function getAppTokenStatus() {
    getAppToken();
    console.log("App token status is " + app_token_status)
    if (track_id == 0) {
        app_token_status = "unknown"
        return;
    }
    load("GET", url + "/api/v1/login/authorize/" + track_id, null,
         function(vals) {
             app_token_status = vals["result"]["status"];
         });
}

/*
CryptoJS v3.1.2
code.google.com/p/crypto-js
(c) 2009-2013 by Jeff Mott. All rights reserved.
code.google.com/p/crypto-js/wiki/License
Copyright (c) 2009-2013 Jeff Mott 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
var CryptoJS=CryptoJS||function(g,l){var e={},d=e.lib={},m=function(){},k=d.Base={extend:function(a){m.prototype=this;var c=new m;a&&c.mixIn(a);c.hasOwnProperty("init")||(c.init=function(){c.$super.init.apply(this,arguments)});c.init.prototype=c;c.$super=this;return c},create:function(){var a=this.extend();a.init.apply(a,arguments);return a},init:function(){},mixIn:function(a){for(var c in a)a.hasOwnProperty(c)&&(this[c]=a[c]);a.hasOwnProperty("toString")&&(this.toString=a.toString)},clone:function(){return this.init.prototype.extend(this)}},
p=d.WordArray=k.extend({init:function(a,c){a=this.words=a||[];this.sigBytes=c!=l?c:4*a.length},toString:function(a){return(a||n).stringify(this)},concat:function(a){var c=this.words,q=a.words,f=this.sigBytes;a=a.sigBytes;this.clamp();if(f%4)for(var b=0;b<a;b++)c[f+b>>>2]|=(q[b>>>2]>>>24-8*(b%4)&255)<<24-8*((f+b)%4);else if(65535<q.length)for(b=0;b<a;b+=4)c[f+b>>>2]=q[b>>>2];else c.push.apply(c,q);this.sigBytes+=a;return this},clamp:function(){var a=this.words,c=this.sigBytes;a[c>>>2]&=4294967295<<
32-8*(c%4);a.length=g.ceil(c/4)},clone:function(){var a=k.clone.call(this);a.words=this.words.slice(0);return a},random:function(a){for(var c=[],b=0;b<a;b+=4)c.push(4294967296*g.random()|0);return new p.init(c,a)}}),b=e.enc={},n=b.Hex={stringify:function(a){var c=a.words;a=a.sigBytes;for(var b=[],f=0;f<a;f++){var d=c[f>>>2]>>>24-8*(f%4)&255;b.push((d>>>4).toString(16));b.push((d&15).toString(16))}return b.join("")},parse:function(a){for(var c=a.length,b=[],f=0;f<c;f+=2)b[f>>>3]|=parseInt(a.substr(f,
2),16)<<24-4*(f%8);return new p.init(b,c/2)}},j=b.Latin1={stringify:function(a){var c=a.words;a=a.sigBytes;for(var b=[],f=0;f<a;f++)b.push(String.fromCharCode(c[f>>>2]>>>24-8*(f%4)&255));return b.join("")},parse:function(a){for(var c=a.length,b=[],f=0;f<c;f++)b[f>>>2]|=(a.charCodeAt(f)&255)<<24-8*(f%4);return new p.init(b,c)}},h=b.Utf8={stringify:function(a){try{return decodeURIComponent(escape(j.stringify(a)))}catch(c){throw Error("Malformed UTF-8 data");}},parse:function(a){return j.parse(unescape(encodeURIComponent(a)))}},
r=d.BufferedBlockAlgorithm=k.extend({reset:function(){this._data=new p.init;this._nDataBytes=0},_append:function(a){"string"==typeof a&&(a=h.parse(a));this._data.concat(a);this._nDataBytes+=a.sigBytes},_process:function(a){var c=this._data,b=c.words,f=c.sigBytes,d=this.blockSize,e=f/(4*d),e=a?g.ceil(e):g.max((e|0)-this._minBufferSize,0);a=e*d;f=g.min(4*a,f);if(a){for(var k=0;k<a;k+=d)this._doProcessBlock(b,k);k=b.splice(0,a);c.sigBytes-=f}return new p.init(k,f)},clone:function(){var a=k.clone.call(this);
a._data=this._data.clone();return a},_minBufferSize:0});d.Hasher=r.extend({cfg:k.extend(),init:function(a){this.cfg=this.cfg.extend(a);this.reset()},reset:function(){r.reset.call(this);this._doReset()},update:function(a){this._append(a);this._process();return this},finalize:function(a){a&&this._append(a);return this._doFinalize()},blockSize:16,_createHelper:function(a){return function(b,d){return(new a.init(d)).finalize(b)}},_createHmacHelper:function(a){return function(b,d){return(new s.HMAC.init(a,
d)).finalize(b)}}});var s=e.algo={};return e}(Math);
(function(){var g=CryptoJS,l=g.lib,e=l.WordArray,d=l.Hasher,m=[],l=g.algo.SHA1=d.extend({_doReset:function(){this._hash=new e.init([1732584193,4023233417,2562383102,271733878,3285377520])},_doProcessBlock:function(d,e){for(var b=this._hash.words,n=b[0],j=b[1],h=b[2],g=b[3],l=b[4],a=0;80>a;a++){if(16>a)m[a]=d[e+a]|0;else{var c=m[a-3]^m[a-8]^m[a-14]^m[a-16];m[a]=c<<1|c>>>31}c=(n<<5|n>>>27)+l+m[a];c=20>a?c+((j&h|~j&g)+1518500249):40>a?c+((j^h^g)+1859775393):60>a?c+((j&h|j&g|h&g)-1894007588):c+((j^h^
g)-899497514);l=g;g=h;h=j<<30|j>>>2;j=n;n=c}b[0]=b[0]+n|0;b[1]=b[1]+j|0;b[2]=b[2]+h|0;b[3]=b[3]+g|0;b[4]=b[4]+l|0},_doFinalize:function(){var d=this._data,e=d.words,b=8*this._nDataBytes,g=8*d.sigBytes;e[g>>>5]|=128<<24-g%32;e[(g+64>>>9<<4)+14]=Math.floor(b/4294967296);e[(g+64>>>9<<4)+15]=b;d.sigBytes=4*e.length;this._process();return this._hash},clone:function(){var e=d.clone.call(this);e._hash=this._hash.clone();return e}});g.SHA1=d._createHelper(l);g.HmacSHA1=d._createHmacHelper(l)})();
(function(){var g=CryptoJS,l=g.enc.Utf8;g.algo.HMAC=g.lib.Base.extend({init:function(e,d){e=this._hasher=new e.init;"string"==typeof d&&(d=l.parse(d));var g=e.blockSize,k=4*g;d.sigBytes>k&&(d=e.finalize(d));d.clamp();for(var p=this._oKey=d.clone(),b=this._iKey=d.clone(),n=p.words,j=b.words,h=0;h<g;h++)n[h]^=1549556828,j[h]^=909522486;p.sigBytes=b.sigBytes=k;this.reset()},reset:function(){var e=this._hasher;e.reset();e.update(this._iKey)},update:function(e){this._hasher.update(e);return this},finalize:function(e){var d=
this._hasher;e=d.finalize(e);d.reset();return d.finalize(this._oKey.clone().concat(e))}})})();
/* End of CryptoJS. */

function getSessionToken() {
    load("GET", url + "/api/v1/login", null,
         function (vals) {
             console.log(vals["result"]["challenge"]);
             var passwd = CryptoJS.HmacSHA1(vals["result"]["challenge"], app_token);
             var obj = '{"app_id": "fr.freebox.box-o-fish", "password": "' + passwd + '"}';
             load("POST", url + "/api/v1/login/session", obj,
                  function(vals) {
                      if (vals["success"]) {
                          session_token = vals["result"]["session_token"];
                          console.log(vals["result"]["permissions"]);
                      }
                  });
         });
}

function logout() {
    if (session_token.length ==0)
        return;
    load("POST", url + "/api/v1/login/logout/", null,
         function (vals) {
             session_token = "";
         });
}

function getCallLog(model) {
    model.clear()
    load("GET", url + "/api/v1/call/log/", null,
         function (vals) {
             if (vals["success"])
                 for (var i = 0; i < vals["result"].length; i++) {
                     var dateTime = new Date(vals["result"][i]["datetime"] * 1000);
                     vals["result"][i]["section"] = Format.formatDate(dateTime, Formatter.TimepointSectionRelative);
                     model.append(vals["result"][i]);
                 }
         });
}

function duration(time) {
    if (time < 60) {
        return time + "s"
    } else if (time < 3600) {
        var m = Math.floor(time / 60)
        var s = time - m * 60
        return  m + "m" + s + "s"
    } else {
        var h = Math.floor(time / 3600)
        var m = Math.floor((time - h * 3600) / 60)
        var s = time - h * 3600 - m * 60
        return h + "h" + m + "m" + s + "s"
    }
}

function call(type) {
    if (type == "missed")
        return "image://theme/icon-m-missed-call"
    else if (type == "outgoing")
        return ""
    else
        return "image://theme/icon-m-incoming-call"
}
