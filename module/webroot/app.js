const STATUS={observed:{label:'Signal observe',cls:'fail'},not_observed:{label:'Aucun signal',cls:'ok'},unknown:{label:'Inconnu',cls:'warn'}};
async function post(action){await fetch('/action?cmd='+encodeURIComponent(action),{method:'POST'});await refresh();}
async function refresh(){
 const cards=document.getElementById('cards');
 try{
  const r=await fetch('data/report.json',{cache:'no-store'});
  if(r.ok){
   const data=await r.json();
   document.getElementById('outcome').textContent='Resultat global : '+data.outcome+' — '+(data.generated_at||'date inconnue');
   cards.innerHTML='';
   (data.findings||[]).forEach(f=>{
    const s=STATUS[f.status]||STATUS.unknown;
    const div=document.createElement('article');
    div.className='card '+s.cls;
    div.innerHTML='<h2>'+f.title+'</h2><p><span class="badge '+s.cls+'">'+s.label+'</span></p><p>Correspondances : '+(f.matches||0)+'</p><p>'+(f.advice||'')+'</p>';
    cards.appendChild(div);
   });
  }
 }catch(e){document.getElementById('outcome').textContent='Aucun rapport genere.';cards.innerHTML='';}
}
document.getElementById('start').onclick=()=>post('start');
document.getElementById('stop').onclick=()=>post('stop');
document.getElementById('auto-on').onclick=()=>post('auto-on');
document.getElementById('auto-off').onclick=()=>post('auto-off');
document.getElementById('refresh').onclick=refresh;
refresh();
