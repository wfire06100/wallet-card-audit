(()=>{
 const section=document.createElement('section');
 const heading=document.createElement('h2');heading.textContent='Passive network diagnostics';
 const note=document.createElement('p');note.textContent='Optional expanded log retention, OFF by default. Stop capture and turn Automatic OFF before changing. No HTTPS decryption, proxy or certificate changes. Payloads are unavailable unless already logged. Partial masking only: review before sharing. New captures only; old discarded events cannot be recovered.';
 const toggle=document.createElement('button');toggle.textContent='Network diagnostics: checking…';toggle.disabled=true;
 section.append(heading,note,toggle);$('report').after(section);
 const option=document.createElement('option');option.value='network_passive';option.textContent='Network / tokenization clues (passive)';$('filter').append(option);
 const previousEvents=events;
 events=async function(){
 if($('filter').value!=='network_passive')return previousEvents();
 $('output').textContent=await exec('network.sh','page '+page);
 $('page').textContent='Page '+page;$('prev').disabled=page<=1;$('copybox').hidden=true;
 };
 const show=value=>{toggle.textContent='Network diagnostics: '+value.trim();toggle.disabled=false;};
 toggle.onclick=()=>run(async()=>{show(await exec('network.sh','toggle'));});
 exec('network.sh','status').then(show).catch(e=>{toggle.textContent='Network diagnostics unavailable';$('error').textContent=e.message;});
})();
