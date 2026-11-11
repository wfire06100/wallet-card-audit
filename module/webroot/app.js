const $=id=>document.getElementById(id);let seq=0,busy=false,page=1,lastState=null;
const base='/data/adb/modules/wallet_card_audit';
function exec(script,args){return new Promise((resolve,reject)=>{
 if(!window.ksu||typeof window.ksu.exec!=='function'){reject(Error('Pont root absent : ouvrir la WebUI dans BakaSU.'));return;}
 const cb='wca_'+Date.now()+'_'+seq++;const t=setTimeout(()=>{delete window[cb];reject(Error('Commande sans reponse (30 s).'));},30000);
 window[cb]=(c,o,e)=>{clearTimeout(t);delete window[cb];Number(c)===0?resolve(o):reject(Error('Code '+c+' : '+e+' '+o));};
 try{window.ksu.exec('/system/bin/sh '+base+'/'+script+' '+args,'{}',cb);}catch(e){clearTimeout(t);delete window[cb];reject(e);}
});}
const call=a=>exec('engine.sh',a);
function controls(s){
 $('capture').textContent=s.capture==='stopped'?'Demarrer l audit':'Arreter l audit';
 $('auto').textContent='Automatique : '+(s.auto?'ON':'OFF');
 $('status').textContent='Capture : '+s.capture+' | Automatique : '+(s.auto?'ON':'OFF');
 $('capture').disabled=busy||s.capture==='finalizing';$('auto').disabled=busy;
 $('clear').disabled=busy||s.capture!=='stopped'||s.auto;
}
async function state(){const s=JSON.parse(await call('status'));if(JSON.stringify(s)!==JSON.stringify(lastState)){lastState=s;controls(s);}return s;}
function line(text){const p=document.createElement('p');p.textContent=text;$('report').append(p);}
async function report(){const r=JSON.parse(await call('report'));$('report').replaceChildren();if(!r.available){line('Aucun rapport disponible.');return;}line('Capture : '+r.raw_bytes+' octets | '+r.filtered_lines+' lignes filtrees | '+r.seconds+' s. Resultat Wallet : inconnu.');if(!r.raw_bytes||r.stderr_present)line('Capture vide ou stderr present : consulter Diagnostics.');for(const f of r.findings){const b=document.createElement('button');b.textContent=f.id+' : '+f.matching_lines+' correspondances — consulter';b.onclick=()=>{$('filter').value=f.id;page=1;run(showLogs);};$('report').append(b);}}
async function showLogs(){const f=$('filter').value;if(!['all','provisioning','keystore','attestation','network','crash'].includes(f))throw Error('Filtre invalide');$('output').textContent=await exec('viewer.sh','page '+f+' '+page);$('page').textContent='Page '+page;$('prev').disabled=page<=1;}
async function run(fn,automatic=false){if(busy)return;busy=true;if(lastState)controls(lastState);if(!automatic)$('error').textContent='';try{await fn();}catch(e){$('error').textContent=e.message;}finally{busy=false;if(lastState)controls(lastState);}}
$('capture').onclick=()=>run(async()=>{await call('toggle');const s=await state();if(s.capture==='stopped'){await report();page=1;await showLogs();}});
$('auto').onclick=()=>run(async()=>{await call('auto-toggle');await state();});
$('refresh').onclick=()=>run(async()=>{await state();await report();});
$('diagnostics').onclick=()=>run(async()=>{$('output').textContent=await call('diagnostics');});
$('load').onclick=()=>run(showLogs);$('filter').onchange=()=>{page=1;run(showLogs);};
$('prev').onclick=()=>{if(page>1){page--;run(showLogs);}};$('next').onclick=()=>{page++;run(showLogs);};
$('clear').onclick=()=>{if(confirm('Supprimer les sessions, rapports et journaux internes du module ? Cette action est irreversible.'))run(async()=>{$('output').textContent=await exec('viewer.sh','clear');page=1;$('page').textContent='Page 1';await report();await state();});};
run(async()=>{await state();await report();});
setInterval(()=>{if(!document.hidden&&!busy)run(async()=>{const old=lastState?.capture;const s=await state();if(old&&old!=='stopped'&&s.capture==='stopped')await report();},true);},5000);
