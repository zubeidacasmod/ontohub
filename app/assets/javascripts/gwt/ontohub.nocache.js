function ontohub(){var P='',xb='" for "gwt:onLoadErrorFn"',vb='" for "gwt:onPropertyErrorFn"',ib='"><\/script>',Z='#',Xb='.cache.html',_='/',lb='//',Qb='01C4E8CE91FD0F65904BDC05155ACC9B',Rb='12080F30580EB3DADE9FB857A41A9C65',Sb='29E3F3D3D0B5158140292B155A4F0FD4',Tb='2DCB2C4DD5E728ADED151CD0F81D6458',Ub='5E89486D80933D4F4413ADDCD08F69C8',Wb=':',pb='::',Zb='<script defer="defer">ontohub.onInjectionDone(\'ontohub\')<\/script>',hb='<script id="',sb='=',$='?',ub='Bad handler "',Yb='DOMContentLoaded',Vb='E38A8075EAF55D6DF8C926E25672D297',jb='SCRIPT',gb='__gwt_marker_ontohub',kb='base',cb='baseUrl',T='begin',S='bootstrap',bb='clear.cache.gif',rb='content',Y='end',Kb='gecko',Lb='gecko1_8',U='gwt.codesvr=',V='gwt.hosted=',W='gwt.hybrid',wb='gwt:onLoadErrorFn',tb='gwt:onPropertyErrorFn',qb='gwt:property',Ob='hosted.html?ontohub',Jb='ie6',Ib='ie8',Hb='ie9',yb='iframe',ab='img',zb="javascript:''",Nb='loadExternalRefs',mb='meta',Bb='moduleRequested',X='moduleStartup',Gb='msie',nb='name',Q='ontohub',eb='ontohub.nocache.js',ob='ontohub::',Db='opera',Ab='position:absolute;width:0;height:0;border:none',Fb='safari',db='script',Pb='selectingPermutation',R='startup',fb='undefined',Mb='unknown',Cb='user.agent',Eb='webkit';var m=window,n=document,o=m.__gwtStatsEvent?function(a){return m.__gwtStatsEvent(a)}:null,p=m.__gwtStatsSessionId?m.__gwtStatsSessionId:null,q,r,s,t=P,u={},v=[],w=[],x=[],y=0,z,A;o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:S,millis:(new Date).getTime(),type:T});if(!m.__gwt_stylesLoaded){m.__gwt_stylesLoaded={}}if(!m.__gwt_scriptsLoaded){m.__gwt_scriptsLoaded={}}function B(){var b=false;try{var c=m.location.search;return (c.indexOf(U)!=-1||(c.indexOf(V)!=-1||m.external&&m.external.gwtOnLoad))&&c.indexOf(W)==-1}catch(a){}B=function(){return b};return b}
function C(){if(q&&r){var b=n.getElementById(Q);var c=b.contentWindow;if(B()){c.__gwt_getProperty=function(a){return H(a)}}ontohub=null;c.gwtOnLoad(z,Q,t,y);o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:X,millis:(new Date).getTime(),type:Y})}}
function D(){function e(a){var b=a.lastIndexOf(Z);if(b==-1){b=a.length}var c=a.indexOf($);if(c==-1){c=a.length}var d=a.lastIndexOf(_,Math.min(c,b));return d>=0?a.substring(0,d+1):P}
function f(a){if(a.match(/^\w+:\/\//)){}else{var b=n.createElement(ab);b.src=a+bb;a=e(b.src)}return a}
function g(){var a=F(cb);if(a!=null){return a}return P}
function h(){var a=n.getElementsByTagName(db);for(var b=0;b<a.length;++b){if(a[b].src.indexOf(eb)!=-1){return e(a[b].src)}}return P}
function i(){var a;if(typeof isBodyLoaded==fb||!isBodyLoaded()){var b=gb;var c;n.write(hb+b+ib);c=n.getElementById(b);a=c&&c.previousSibling;while(a&&a.tagName!=jb){a=a.previousSibling}if(c){c.parentNode.removeChild(c)}if(a&&a.src){return e(a.src)}}return P}
function j(){var a=n.getElementsByTagName(kb);if(a.length>0){return a[a.length-1].href}return P}
function k(){var a=n.location;return a.href==a.protocol+lb+a.host+a.pathname+a.search+a.hash}
var l=g();if(l==P){l=h()}if(l==P){l=i()}if(l==P){l=j()}if(l==P&&k()){l=e(n.location.href)}l=f(l);t=l;return l}
function E(){var b=document.getElementsByTagName(mb);for(var c=0,d=b.length;c<d;++c){var e=b[c],f=e.getAttribute(nb),g;if(f){f=f.replace(ob,P);if(f.indexOf(pb)>=0){continue}if(f==qb){g=e.getAttribute(rb);if(g){var h,i=g.indexOf(sb);if(i>=0){f=g.substring(0,i);h=g.substring(i+1)}else{f=g;h=P}u[f]=h}}else if(f==tb){g=e.getAttribute(rb);if(g){try{A=eval(g)}catch(a){alert(ub+g+vb)}}}else if(f==wb){g=e.getAttribute(rb);if(g){try{z=eval(g)}catch(a){alert(ub+g+xb)}}}}}}
function F(a){var b=u[a];return b==null?null:b}
function G(a,b){var c=x;for(var d=0,e=a.length-1;d<e;++d){c=c[a[d]]||(c[a[d]]=[])}c[a[e]]=b}
function H(a){var b=w[a](),c=v[a];if(b in c){return b}var d=[];for(var e in c){d[c[e]]=e}if(A){A(a,d,b)}throw null}
var I;function J(){if(!I){I=true;var a=n.createElement(yb);a.src=zb;a.id=Q;a.style.cssText=Ab;a.tabIndex=-1;n.body.appendChild(a);o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:X,millis:(new Date).getTime(),type:Bb});a.contentWindow.location.replace(t+L)}}
w[Cb]=function(){var b=navigator.userAgent.toLowerCase();var c=function(a){return parseInt(a[1])*1000+parseInt(a[2])};if(function(){return b.indexOf(Db)!=-1}())return Db;if(function(){return b.indexOf(Eb)!=-1}())return Fb;if(function(){return b.indexOf(Gb)!=-1&&n.documentMode>=9}())return Hb;if(function(){return b.indexOf(Gb)!=-1&&n.documentMode>=8}())return Ib;if(function(){var a=/msie ([0-9]+)\.([0-9]+)/.exec(b);if(a&&a.length==3)return c(a)>=6000}())return Jb;if(function(){return b.indexOf(Kb)!=-1}())return Lb;return Mb};v[Cb]={gecko1_8:0,ie6:1,ie8:2,ie9:3,opera:4,safari:5};ontohub.onScriptLoad=function(){if(I){r=true;C()}};ontohub.onInjectionDone=function(){q=true;o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:Nb,millis:(new Date).getTime(),type:Y});C()};E();D();var K;var L;if(B()){if(m.external&&(m.external.initModule&&m.external.initModule(Q))){m.location.reload();return}L=Ob;K=P}o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:S,millis:(new Date).getTime(),type:Pb});if(!B()){try{G([Fb],Qb);G([Jb],Rb);G([Lb],Sb);G([Hb],Tb);G([Db],Ub);G([Ib],Vb);K=x[H(Cb)];var M=K.indexOf(Wb);if(M!=-1){y=Number(K.substring(M+1));K=K.substring(0,M)}L=K+Xb}catch(a){return}}var N;function O(){if(!s){s=true;C();if(n.removeEventListener){n.removeEventListener(Yb,O,false)}if(N){clearInterval(N)}}}
if(n.addEventListener){n.addEventListener(Yb,function(){J();O()},false)}var N=setInterval(function(){if(/loaded|complete/.test(n.readyState)){J();O()}},50);o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:S,millis:(new Date).getTime(),type:Y});o&&o({moduleName:Q,sessionId:p,subSystem:R,evtGroup:Nb,millis:(new Date).getTime(),type:T});n.write(Zb)}
ontohub();