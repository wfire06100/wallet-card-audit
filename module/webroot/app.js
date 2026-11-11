const $=id=>document.getElementById(id);let sequence=0,busy=false;
function shell(cmd){return new Promise((resolve,reject)=>{
 if(!window.ksu||typeof window.ksu.exec!=='function'){reject(Error('Pont BakaSU/KernelSU absent : ouvrir dans la WebUI du gestionnaire.'));return;}
 const name='wca_'+Date.now()+'_'+sequence++;
 const timer=setTimeout(()=>{delete window[name];reject(Error('Commande sans reponse apres 30 secondes.'));},30000);
 window[name]=(code,out,err)=>{clearTimeout(timer);delete window[name];Number(code)===0?resolve(out):reject(Error('Code '+code+' : '+err+' '+out));};
 try{window.ksu.exec(cmd,'{}',name);}catch(e){clearTimeout(timer);delete window[name];reject(e);}
});}
const base='/data/adb/modules/wallet_card_audit';
async function call(action){return shell('/system/bin/sh '+base+'/engine.sh '+action);}
async function update(){
 const s=JSON.parse(await call('status'));
 $('status').textContent='Backend '+s.version+' | Capture : '+s.capture+' | Automatique : '+(s.auto?'ON':'OFF');
 $('capture').textContent=s.capture==='stopped'?'Demarrer l audit':'Arreter l audit';$('auto').textContent='Automatique : '+(s.auto?'ON':'OFF');
 $('capture').disabled=busy||s.capture==='finalizing';$('auto').disabled=busy;
 const r=JSON.parse(await call('report'));
 $('report').replaceChildren();
 function line(text){const p=document.createElement('p');p.textContent=text;$('report').append(p);}
 if(!r.available){line('Aucun rapport : lancer puis arreter une capture.');return;}
 line('Capture : '+r.raw_bytes+' octets | '+r.filtered_lines+' lignes filtrees | '+r.seconds+' s. Resultat Wallet : inconnu.');
 if(r.raw_bytes===0||r.stderr_present)line('Verifier Diagnostics : capture vide ou sortie stderr presente.');
 for(const f of r.findings)line(f.id+' : '+f.matching_lines+' ligne(s). Indice uniquement, pas une cause prouvee.');
}
async function run(action){if(busy)return;busy=true;$('error').textContent='';$('capture').disabled=true;$('auto').disabled=true;
 try{if(action){const out=await call(action);if(action==='diagnostics'||action==='logs')$('output').textContent=out;}busy=false;await update();}catch(e){$('error').textContent=e.message;}finally{busy=false;}}
$('capture').onclick=()=>run('toggle');$('auto').onclick=()=>run('auto-toggle');$('refresh').onclick=()=>run();$('diagnostics').onclick=()=>run('diagnostics');$('logs').onclick=()=>run('logs');run();setInterval(()=>{if(!busy)run();},5000);
