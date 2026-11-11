const $=id=>document.getElementById(id);let seq=0,busy=false,page=1,current=null,timer;
const base='/data/adb/modules/wallet_card_audit';
function exec(script,args){return new Promise((resolve,reject)=>{
 if(!window.ksu||typeof window.ksu.exec!=='function')return reject(Error('Root bridge unavailable. Open this WebUI in BakaSU.'));
 const cb='wca_'+Date.now()+'_'+seq++;const t=setTimeout(()=>{delete window[cb];reject(Error('Command timed out after 30 seconds.'));},30000);
 window[cb]=(c,o,e)=>{clearTimeout(t);delete window[cb];Number(c)===0?resolve(o):reject(Error('Command failed ('+c+'): '+e+' '+o));};
 try{window.ksu.exec('/system/bin/sh '+base+'/'+script+' '+args,'{}',cb);}catch(e){clearTimeout(t);delete window[cb];reject(e);}
});}
const call=a=>exec('engine.sh',a);
function controls(){
 const s=current;if(!s)return;
 const labels={stopped:'Stopped',starting:'Starting',capturing:'Capturing',finalizing:'Generating report'};
 const text='Capture: '+(labels[s.capture]||s.capture)+' | Automatic: '+(s.auto?'ON':'OFF');if($('status').textContent!==text)$('status').textContent=text;
 const cap=s.capture==='stopped'?'Start capture':'Stop capture';if($('capture').textContent!==cap)$('capture').textContent=cap;
 const auto='Automatic: '+(s.auto?'ON':'OFF');if($('auto').textContent!==auto)$('auto').textContent=auto;
 $('capture').disabled=busy||s.capture==='finalizing';$('auto').disabled=busy;$('clear').disabled=busy;
}
async function state(){const old=current?.capture;current=JSON.parse(await call('status'));controls();return old;}
async function report(){const r=JSON.parse(await call('report'));$('report').replaceChildren();const line=t=>{const p=document.createElement('p');p.textContent=t;$('report').append(p);};if(!r.available){line('No report available.');return;}line('Captured: '+r.raw_bytes+' bytes | '+r.filtered_lines+' filtered lines | '+r.seconds+' s. Wallet result: unknown.');if(!r.raw_bytes||r.stderr_present)line('Empty capture or stderr present: open Diagnostics.');for(const f of r.findings){const b=document.createElement('button');b.textContent=f.id+': '+f.matching_lines+' matches — view';b.onclick=()=>{if(busy)return;$('filter').value=f.id;page=1;run(events);};$('report').append(b);}}
async function events(){const f=$('filter').value;if(!['all','provisioning','keystore','attestation','network','crash'].includes(f))throw Error('Invalid filter');$('output').textContent=await exec('viewer.sh','page '+f+' '+page);$('page').textContent='Page '+page;$('prev').disabled=page<=1;$('copybox').hidden=true;}
async function run(fn,silent=false){if(busy)return;busy=true;controls();if(!silent){$('error').textContent='';$('notice').textContent='Working…';}try{await fn();if(!silent&&$('notice').textContent==='Working…')$('notice').textContent='Done.';}catch(e){$('error').textContent=e.message;$('notice').textContent='';}finally{busy=false;controls();schedule();}}
function schedule(){clearTimeout(timer);if(document.hidden)return;timer=setTimeout(()=>run(async()=>{const old=await state();if(old&&old!=='stopped'&&current.capture==='stopped')await report();},true),current?.capture==='stopped'&&!current?.auto?15000:5000);}
$('capture').onclick=()=>run(async()=>{await call('toggle');await state();if(current.capture==='stopped'){await report();page=1;await events();}});
$('auto').onclick=()=>run(async()=>{await call('auto-toggle');await state();});
$('refresh').onclick=()=>run(async()=>{await state();await report();});
$('diagnostics').onclick=()=>run(async()=>{$('output').textContent=await call('diagnostics');});
$('load').onclick=()=>run(events);$('filter').onchange=()=>{if(!busy){page=1;run(events);}};
$('prev').onclick=()=>{if(!busy&&page>1){page--;run(events);}};$('next').onclick=()=>{if(!busy){page++;run(events);}};
$('clear').onclick=()=>{if(busy)return;if(current?.capture!=='stopped'||current?.auto){$('error').textContent='Stop capture and turn Automatic OFF before deleting logs.';return;}$('confirm').showModal();};
$('cancel').onclick=()=>$('confirm').close();
$('delete').onclick=()=>{$('confirm').close();run(async()=>{const result=await exec('viewer.sh','clear');page=1;$('page').textContent='Page 1';$('output').textContent='No events: logs deleted.';$('copybox').value='';$('copybox').hidden=true;await report();await state();$('notice').textContent=result;});};
$('copy').onclick=async()=>{const text=$('output').textContent;try{if(!navigator.clipboard?.writeText)throw Error('Clipboard unavailable');await navigator.clipboard.writeText(text);$('notice').textContent='Displayed events copied.';}catch(e){const box=$('copybox');box.hidden=false;box.value=text;box.focus();box.select();let ok=false;try{ok=document.execCommand('copy');}catch(_){}$('notice').textContent=ok?'Displayed events copied.':'Automatic copy unavailable. Text selected below: use Android Copy.';if(ok)box.hidden=true;}};
document.addEventListener('visibilitychange',()=>{clearTimeout(timer);if(!document.hidden&&!busy)run(state,true);});
run(async()=>{await state();await report();});
