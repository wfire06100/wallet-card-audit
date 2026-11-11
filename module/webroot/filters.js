(()=>{
 const select=$('filter');
 const terms={keystore_literal:'Keystore',tapandpay:'TapAndPay',gms:'GMS',keymint_interceptor:'KeyMintSecurityLevelInterceptor',system_logger:'SystemLogger',software_operation:'SoftwareOperation',operation_interceptor:'OperationInterceptor',create_operation:'createOperation',generate_key:'generateKey',authorize_create:'authorizecreate',network_monitor:'NetworkMonitor',keymaster_utils:'KeymasterUtils',tokenization:'tokenization',pay:'Pay'};
 for(const [value,label] of Object.entries(terms)){const o=document.createElement('option');o.value=value;o.textContent=label;select.append(o);}
 const custom=document.createElement('option');custom.value='custom';custom.textContent='Custom text…';select.append(custom);
 const input=$('custom');
 const original=events;
 events=async function(){
 const f=select.value;
 if(!(f in terms)&&f!=='custom')return original();
 const text=f==='custom'?input.value:terms[f];
 const bytes=new TextEncoder().encode(text);
 if(!text.trim()||bytes.length>500)throw Error('Enter 1–500 UTF-8 bytes of search text.');
 const encoded=btoa(Array.from(bytes,b=>String.fromCharCode(b)).join(''));
 $('output').textContent=await exec('search.sh',encoded+' '+page);
 $('page').textContent='Page '+page;$('prev').disabled=page<=1;$('copybox').hidden=true;
 };
 input.addEventListener('keydown',e=>{if(e.key==='Enter'&&!busy){page=1;run(events);}});
 $('apply').onclick=()=>{if(!busy){page=1;run(events);}};
 select.onchange=()=>{input.hidden=select.value!=='custom';if(select.value!=='custom'&&!busy){page=1;run(events);}};
 const heading=document.querySelector('h1');if(heading)heading.textContent='Wallet Card Audit 0.5.6';
})();
