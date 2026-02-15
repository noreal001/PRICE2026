
<template>
  <div class="bahur-terminal" :style="themeVars">
    <!-- SVG Liquid Glass Filter -->
    <svg style="position:absolute;width:0;height:0;overflow:hidden">
      <defs>
        <filter id="liquid-glass" x="-5%" y="-5%" width="110%" height="110%">
          <feTurbulence type="fractalNoise" :baseFrequency="lgNoise" numOctaves="2" seed="42" result="noise"/>
          <feGaussianBlur in="noise" stdDeviation="3" result="blurred"/>
          <feDisplacementMap in="SourceGraphic" in2="blurred" :scale="lgDistort" xChannelSelector="R" yChannelSelector="G"/>
        </filter>
      </defs>
    </svg>

    <div class="container">
      <!-- Loading -->
      <div v-if="loading" class="lo"><div class="lo-bg"></div><div class="lo-c"><span class="lo-t main-font">BAHUR</span></div></div>

      <!-- Error -->
      <div v-if="errorMsg" class="ez"><div class="eb"><div style="font-size:24px;margin-bottom:15px;opacity:.5">✕</div><h3 class="mono" style="font-size:13px;margin-bottom:10px;letter-spacing:1.5px">ОШИБКА</h3><p style="font-size:11px;color:var(--dim);margin-bottom:25px">{{ errorMsg }}</p><button @click="loadData" style="background:var(--text);border:none;color:var(--bg);padding:10px 24px;font-size:10px;cursor:pointer;font-weight:700;letter-spacing:1px;border-radius:6px" class="mono">ПОВТОРИТЬ</button></div></div>

      <div v-else-if="!loading">
        <!-- Overlay -->
        <div v-if="anyMenuOpen" class="co" @click="closeAllMenus"></div>

        <div class="tf">
          <!-- Sticky Header -->
          <div class="sn liquid-el" :style="lgStyle">
            <!-- Stats tab — subtle arrow -->
            <button @click="showDash=!showDash" :class="['stats-tab',{active:showDash}]">
              <span class="stats-arrow" :class="{flip:showDash}">▾</span>
            </button>

            <!-- Table header -->
            <div class="th" :class="'sz-'+cardSize">
              <div class="hn hid"><span class="hp nhp mono">#</span></div>
              <div class="hn hbrand" ref="brandBtnRef">
                <button @click="toggleBrandMenu" :class="['hp hdr-click kollektif',{active:showBrandMenu||selectedBrands.length>0}]">
                  <svg class="search-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                  <span>{{ brandLabel }}</span>
                </button>
              </div>
              <div class="hn haroma" ref="fragBtnRef">
                <button @click="toggleFragMenu" :class="['hp hdr-click kollektif',{active:showFragMenu||selectedFrags.length>0}]">
                  <svg class="search-ico" viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                  <span>{{ fragLabel }}</span>
                </button>
              </div>
              <div class="hpl do"><span class="hp mhp kollektif">ПОЛ</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">ФАБРИКА</span></div>
              <div class="hpl do"><span class="hp mhp kollektif">КАЧЕСТВО</span></div>
              <div class="hpr" :style="psg"><div v-if="showPrices.p50" class="hpl"><span class="hp php mono">50г</span></div><div v-if="showPrices.p500" class="hpl"><span class="hp php mono">500г</span></div><div v-if="showPrices.p1000" class="hpl"><span class="hp php mono">1кг</span></div></div>
            </div>
          </div>

          <!-- Dashboard -->
          <div :class="['dw',{open:showDash}]"><div class="dc"><section class="dg">
            <div class="sc"><label class="sl">АРОМАТЫ</label><div class="sv mono">{{ stats.total }}</div><div class="ss"><span>Есть: <b class="mono">{{ stats.countAvail }}</b></span><span>Нет: <b class="mono">{{ stats.countOut }}</b></span></div></div>
            <div class="sc"><label class="sl">СКЛАД</label><div class="sv mono">{{ stats.availability }}%</div><div class="bt"><div class="bf" :style="{width:stats.availability+'%'}"></div></div></div>
            <div class="sc"><label class="sl">СРЕДНЯЯ ЦЕНА</label><div class="sp2"><div v-if="showPrices.p50" class="sp3">50г: <span class="mono">{{ stats.avg50 }}₽</span></div><div v-if="showPrices.p500" class="sp3">500г: <span class="mono">{{ stats.avg500 }}₽</span></div><div v-if="showPrices.p1000" class="sp3">1кг: <span class="mono">{{ stats.avg1000 }}₽</span></div></div></div>
            <div class="sc sc-right"><label class="sl">ФАБРИКИ</label><div v-for="f in ['LUZI','EPS','SELUZ']" :key="f" class="br"><div class="bm"><span class="mono">{{ f }}</span><span class="mono">{{ stats.factoryPerc[f] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.factoryPerc[f]+'%'}"></div></div></div></div>
            <div class="sc sc-right"><label class="sl">КАЧЕСТВО</label><div v-for="q in ['TOP','Q1','Q2']" :key="q" class="br"><div class="bm"><span class="mono">{{ q }}</span><span class="mono">{{ stats.qualityPerc[q] }}%</span></div><div class="bn"><div class="bf" :style="{width:stats.qualityPerc[q]+'%'}"></div></div></div></div>
            <div class="sc sw2"><div style="display:flex;justify-content:center;margin-bottom:6px"><button @click="toggleStatsMode" class="tsw main-font"><span style="color:var(--dim)">РЕЙТИНГ:</span> {{ statsMode==='6m'?'6 МЕС':'ВСЕ ВРЕМЯ' }} ⇄</button></div><div class="tsc"><div v-for="(item,idx) in stats.topListFull" :key="idx" class="tr2"><div class="tl"><span class="tn mono">{{ idx+1 }}.</span><span class="tname kollektif">{{ item.name }}</span></div><div class="tb2"><div class="tbd">{{ item.factory }}</div><div class="tbd">{{ item.quality }}</div><div class="tbd tbh">{{ statsMode==='6m'?item.sales6m:item.salesAll }}%</div></div><div style="display:flex;align-items:center"><div class="bn"><div class="bf" :style="{width:(statsMode==='6m'?item.sales6m:item.salesAll)+'%'}"></div></div></div></div><div v-if="!stats.topListFull.length" class="mono" style="font-size:10px;opacity:.5">НЕТ ДАННЫХ</div></div></div>
          </section></div></div>

          <!-- Popups -->
          <teleport to="body">
            <transition name="pop"><div v-if="showBrandMenu" class="popup-teleport" :style="[brandMenuStyle,pVars]"><div style="width:100%"><input v-model="tempBrandInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК БРЕНДА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearBrands" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="bbtn main-font"><span class="btx">{{ b }}</span><svg v-if="selectedBrands.includes(b)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredBrandsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <transition name="pop"><div v-if="showFragMenu" class="popup-teleport" :style="[fragMenuStyle,pVars]"><div style="width:100%"><input v-model="tempFragInput" type="search" inputmode="search" enterkeyhint="search" placeholder="ПОИСК АРОМАТА…" class="pinp main-font"/></div><div class="bsc"><button @click="clearFrags" class="bbtn ab main-font"><svg style="width:14px;height:14px;flex-shrink:0" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z"/></svg><span>ВСЕ</span></button><button v-for="f in filteredFragsDropdown" :key="f" @click="toggleFragSelection(f)" class="bbtn main-font"><span class="btx">{{ f }}</span><svg v-if="selectedFrags.includes(f)" style="width:13px;height:13px" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/></svg></button><div v-if="!filteredFragsDropdown.length" style="font-size:10px;color:var(--dim);padding:6px 10px" class="main-font">НЕТ СОВПАДЕНИЙ</div></div></div></transition>
            <!-- Filters cascade -->
            <transition name="cascade">
              <div v-if="showFilters" class="filter-cascade" :style="pVars">
                <div class="fc-overlay" @click="showFilters=false"></div>
                <div class="fc-panel">
                  <div class="fc-handle"></div>
                  <div class="fc-head"><span class="fc-title main-font">ФИЛЬТРЫ</span><button @click="showFilters=false" class="fc-close">✕</button></div>
                  <!-- Размер -->
                  <div class="ps">
                    <span class="pl main-font">РАЗМЕР</span>
                    <div class="sg">
                      <button @click="cardSize='s'" :class="['sgb main-font',{active:cardSize==='s'}]">
                        <svg width="12" height="12" viewBox="0 0 24 24"><path fill="currentColor" d="M19 13H5v-2h14v2z"/></svg>
                      </button>
                      <button @click="cardSize='m'" :class="['sgb main-font',{active:cardSize==='m'}]">
                        <svg width="14" height="14" viewBox="0 0 24 24"><path fill="currentColor" d="M4 8h4V4H4v4zm6 12h4v-4h-4v4zm-6 0h4v-4H4v4zm0-6h4v-4H4v4zm6 0h4v-4h-4v4zm6-10v4h4V4h-4zm-6 4h4V4h-4v4zm6 6h4v-4h-4v4zm0 6h4v-4h-4v4z"/></svg>
                      </button>
                      <button @click="cardSize='l'" :class="['sgb main-font',{active:cardSize==='l'}]">
                        <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M19 11H5v-2h14v2zm0 4H5v-2h14v2zm0 4H5v-2h14v2zm0-12H5V5h14v2z"/></svg>
                      </button>
                    </div>
                  </div>
                  <!-- Дизайн -->
                  <div class="ps">
                    <span class="pl main-font">ДИЗАЙН</span>
                    <div class="theme-toggle" @click="toggleTheme">
                      <span :class="['tt-label main-font',{active:curTheme==='graphite'}]">ТЁМНАЯ</span>
                      <div :class="['tt-track',{light:curTheme==='powder'}]"><div class="tt-thumb"></div></div>
                      <span :class="['tt-label main-font',{active:curTheme==='powder'}]">СВЕТЛАЯ</span>
                    </div>
                  </div>
                  <!-- Новинки -->
                  <div class="ps">
                    <span class="pl main-font">НОВИНКИ</span>
                    <div class="tgr" @click="filterPlus=!filterPlus"><span class="tgl main-font">НОВИНКИ <span class="ch chp">+</span></span><div :class="['tg',{on:filterPlus}]"><div class="tgt"></div></div></div>
                    <div class="tgr" @click="filterStar=!filterStar"><span class="tgl main-font">ВЕРСИИ <span class="ch chs">*</span></span><div :class="['tg',{on:filterStar}]"><div class="tgt"></div></div></div>
                    <div class="tgr" @click="showOut=!showOut"><span class="tgl main-font">НЕТ <span class="ch chm">-</span></span><div :class="['tg',{on:showOut}]"><div class="tgt"></div></div></div>
                  </div>
                  <!-- Пол -->
                  <div class="ps"><span class="pl main-font">ПОЛ</span><div class="sg"><button v-for="g in genderOptions" :key="g.val" @click="activeGender=g.val" :class="['sgb main-font',{active:activeGender===g.val}]">{{ g.label }}</button></div></div>
                  <!-- Фабрика -->
                  <div class="ps"><span class="pl main-font">ФАБРИКА</span><div class="sg"><button v-for="f in factoryOptions" :key="f.val" @click="activeFactory=f.val" :class="['sgb main-font',{active:activeFactory===f.val}]">{{ f.label }}</button></div></div>
                  <!-- Качество -->
                  <div class="ps"><span class="pl main-font">КАЧЕСТВО</span><div class="sg"><button v-for="q in qualityOptions" :key="q.val" @click="activeQuality=q.val" :class="['sgb main-font',{active:activeQuality===q.val}]">{{ q.label }}</button></div></div>
                  <!-- Цена -->
                  <div class="ps"><span class="pl main-font">СОРТИРОВКА</span><div class="sg"><button v-for="s in sortOptions" :key="s.val" @click="sortBy=s.val" :class="['sgb main-font',{active:sortBy===s.val}]"><span v-if="s.val==='id'">ID</span><span v-else>{{ s.label }}{{ s.val==='asc'?' ▲':' ▼' }}</span></button></div></div>
                  <!-- Столбцы -->
                  <div class="ps"><span class="pl main-font">СТОЛБЦЫ</span><div class="sg"><button v-for="(val,key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['sgb main-font',{active:showPrices[key]}]">{{ val }}</button></div></div>
                </div>
              </div>
            </transition>
          </teleport>

          <!-- Products -->
          <div class="gt" :class="'sz-'+cardSize">
            <div v-for="(p,index) in sortedProducts" :key="p.id+'-'+index" :class="['row','cr',{out:p.isOut}]" @click="p.link&&p.link.length>5?openLink(p.link):null">
              <div class="rc">
                <div class="cn cid"><span class="id-num mono">{{ p.id }}<span v-if="p.isOut" class="id-st st-out">-</span><span v-else-if="p.hasPlus" class="id-st st-plus">+</span><span v-else-if="p.hasStar" class="id-st st-star">*</span></span></div>
                <div class="cn cbrand"><div class="pn pn-brand"><span class="bc kollektif">{{ p.brand }}</span></div></div>
                <div class="cn caroma"><div class="pn pn-aroma">
                  <span class="st2 kollektif">{{ p.name }}</span>
                  <div class="mm"><span class="mb kollektif">{{ getSex(p.gender) }}</span><span class="mb kollektif">{{ p.factory }}</span><span class="mb kollektif">{{ p.quality }}</span></div>
                </div></div>
                <div class="cm do center"><div class="pm kollektif">{{ getSex(p.gender) }}</div></div>
                <div class="cm do center"><div class="pm kollektif">{{ p.factory }}</div></div>
                <div class="cm do center"><div class="pm kollektif">{{ p.quality }}</div></div>
                <div class="cp" :style="psg">
                  <div v-if="showPrices.p50" class="pp mono">{{ p.p50 }}<span class="pp-cur">₽</span></div>
                  <div v-if="showPrices.p500" class="pp mono">{{ p.p500 }}<span class="pp-cur">₽</span></div>
                  <div v-if="showPrices.p1000" class="pp pp-main mono">{{ p.p1000 }}<span class="pp-cur">₽</span></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- FAB Filter -->
    <button v-if="!loading&&!errorMsg" @click="showFilters=!showFilters" :class="['fab-filter liquid-el',{active:showFilters}]" :style="lgStyle">
      <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M3 17v2h6v-2H3zM3 5v2h10V5H3zm10 16v-2h8v-2h-8v-2h-2v6h2zM7 9v2H3v2h4v2h2V9H7zm14 4v-2H11v2h10zm-6-4h2V7h4V5h-4V3h-2v6z"/></svg>
    </button>

    <!-- Scroll Track -->
    <div v-if="!loading&&!errorMsg" class="strack" ref="scrollTrack" @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick"><div class="sthumb" :style="{top:thumbTop+'%',height:thumbHeight+'%'}"></div></div>
  </div>
</template>

<script setup>
import{ref,computed,onMounted,onUnmounted,nextTick,watch}from'vue'

// ── Liquid Glass ──
const lgBlur=ref(Number(localStorage.getItem('lg-blur'))||16)
const lgNoise=ref(Number(localStorage.getItem('lg-noise'))||0.012)
const lgDistort=ref(Number(localStorage.getItem('lg-distort'))||40)
const lgTint=ref(Number(localStorage.getItem('lg-tint'))||30)
const lgStyle=computed(()=>({'--lg-blur':lgBlur.value+'px','--lg-tint-opacity':lgTint.value/100}))
watch([lgBlur,lgNoise,lgDistort,lgTint],()=>{localStorage.setItem('lg-blur',lgBlur.value);localStorage.setItem('lg-noise',lgNoise.value);localStorage.setItem('lg-distort',lgDistort.value);localStorage.setItem('lg-tint',lgTint.value)})

// ── Themes ──
const saved=localStorage.getItem('bahur-theme')
const curTheme=ref(saved==='powder'?'powder':'graphite')

const T={
graphite:{bg:'#0c0c0e',text:'#e0e0e4',cBg:'#141416',pP:'#18181c',pM:'#141416',pN:'#141416',brd:'rgba(255,255,255,0.05)',dim:'#4a4a50',hBg:'#1c1c20',sBg:'rgba(12,12,14,0.92)',seBg:'#0a0a0c',seA:'#e0e0e4',seT:'#4a4a50',seTA:'#0a0a0c',panBg:'#111114',gBase:'rgba(0,0,0,0.35)',gBrd:'rgba(255,255,255,0.06)',gShine:'rgba(255,255,255,0.04)',acc:'#888890',tRgb:'20,20,22',fabBg:'rgba(14,14,18,0.85)',fabBrd:'rgba(255,255,255,0.08)'},
powder:{bg:'#f4f0ec',text:'#1a1618',cBg:'#faf7f5',pP:'#f0ebe7',pM:'#f0ebe7',pN:'#f7f3f0',brd:'rgba(0,0,0,0.06)',dim:'#a09088',hBg:'#ede7e3',sBg:'rgba(244,240,236,0.92)',seBg:'#e4ddd8',seA:'#1a1618',seT:'#a09088',seTA:'#faf7f5',panBg:'#f7f3f0',gBase:'rgba(255,255,255,0.45)',gBrd:'rgba(0,0,0,0.06)',gShine:'rgba(255,255,255,0.6)',acc:'#605048',tRgb:'250,247,245',fabBg:'rgba(247,243,240,0.88)',fabBrd:'rgba(0,0,0,0.08)'}
}

const themeVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--bg':t.bg,'--text':t.text,'--card-bg':t.cBg,'--pill-price':t.pP,'--pill-meta':t.pM,'--pill-name':t.pN,'--border':t.brd,'--card-border':t.brd,'--dim':t.dim,'--hover-bg':t.hBg,'--sticky-bg':t.sBg,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--panel-bg':t.panBg,'--glass-base':t.gBase,'--glass-brd':t.gBrd,'--glass-shine':t.gShine,'--accent':t.acc,'--p-cols':activePriceCount.value,'--text-rgb':t.tRgb,'--fab-bg':t.fabBg,'--fab-brd':t.fabBrd}})
const pVars=computed(()=>{const t=T[curTheme.value]||T.graphite;return{'--panel-bg':t.panBg,'--border':t.brd,'--text':t.text,'--dim':t.dim,'--seg-bg':t.seBg,'--seg-active':t.seA,'--seg-txt':t.seT,'--seg-txt-active':t.seTA,'--bg':t.bg,'--card-bg':t.cBg,'--text-rgb':t.tRgb,color:t.text}})

const toggleTheme=()=>{curTheme.value=curTheme.value==='graphite'?'powder':'graphite'}
watch(curTheme,v=>{localStorage.setItem('bahur-theme',v)})

// ── Data ──
const loading=ref(true),errorMsg=ref(null),products=ref([]),showDash=ref(false),statsMode=ref('6m')
const toggleStatsMode=()=>{statsMode.value=statsMode.value==='6m'?'all':'6m'}

// ── Filters ──
const selectedBrands=ref([]),tempBrandInput=ref(''),showBrandMenu=ref(false)
const selectedFrags=ref([]),tempFragInput=ref(''),showFragMenu=ref(false)
const showFilters=ref(false)
const filterPlus=ref(false),filterStar=ref(false),showOut=ref(false)
const activeGender=ref('ВСЕ'),activeQuality=ref('ВСЕ'),sortBy=ref('id'),activeFactory=ref('ВСЕ')

const showPrices=ref({p50:true,p500:true,p1000:true}),priceLabels={p50:'50г',p500:'500г',p1000:'1кг'}
const activePriceCount=computed(()=>Object.values(showPrices.value).filter(Boolean).length)
const cardSize=ref('m')

const anyMenuOpen=computed(()=>showBrandMenu.value||showFragMenu.value)
const genderOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'МУЖ',val:'m'},{label:'ЖЕН',val:'w'},{label:'УНИ',val:'y'}]
const factoryOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'LUZI',val:'LUZI'},{label:'EPS',val:'EPS'},{label:'SELUZ',val:'SELUZ'}]
const qualityOptions=[{label:'ВСЕ',val:'ВСЕ'},{label:'TOP',val:'TOP'},{label:'Q1',val:'Q1'},{label:'Q2',val:'Q2'}]
const sortOptions=[{label:'ID',val:'id'},{label:'ЦЕНА',val:'asc'},{label:'ЦЕНА',val:'desc'}]
const togglePrice=k=>{if(showPrices.value[k]&&Object.values(showPrices.value).filter(Boolean).length===1)return;showPrices.value[k]=!showPrices.value[k]}

// ── Menus ──
const brandBtnRef=ref(null),fragBtnRef=ref(null)
const brandMenuStyle=ref({}),fragMenuStyle=ref({})

function calcP(r,pw=280){const el=r?.value;if(!el)return{};const b=el.getBoundingClientRect(),vw=window.innerWidth;if(vw<=900)return{position:'fixed',top:(b.bottom+6)+'px',left:'12px',width:(vw-24)+'px',zIndex:9999};let l=b.left+b.width/2-pw/2;if(l+pw>vw-12)l=vw-pw-12;if(l<12)l=12;return{position:'fixed',top:(b.bottom+6)+'px',left:l+'px',width:pw+'px',zIndex:9999}}
const recP=()=>{if(showBrandMenu.value)brandMenuStyle.value=calcP(brandBtnRef);if(showFragMenu.value)fragMenuStyle.value=calcP(fragBtnRef)}

const closeAllMenus=()=>{showBrandMenu.value=false;showFragMenu.value=false}
const toggleBrandMenu=async()=>{if(showBrandMenu.value){closeAllMenus();return}closeAllMenus();tempBrandInput.value='';await nextTick();brandMenuStyle.value=calcP(brandBtnRef);showBrandMenu.value=true}
const toggleFragMenu=async()=>{if(showFragMenu.value){closeAllMenus();return}closeAllMenus();tempFragInput.value='';await nextTick();fragMenuStyle.value=calcP(fragBtnRef);showFragMenu.value=true}

const toggleBrandSelection=b=>{const i=selectedBrands.value.indexOf(b);i===-1?selectedBrands.value.push(b):selectedBrands.value.splice(i,1);closeAllMenus()}
const clearBrands=()=>{selectedBrands.value=[];closeAllMenus()}
const brandLabel=computed(()=>{const n=selectedBrands.value.length;return n===0?'БРЕНД':`${n} БРЕНД${n>1?'А':''}`})

const toggleFragSelection=f=>{const i=selectedFrags.value.indexOf(f);i===-1?selectedFrags.value.push(f):selectedFrags.value.splice(i,1);closeAllMenus()}
const clearFrags=()=>{selectedFrags.value=[];closeAllMenus()}
const fragLabel=computed(()=>{const n=selectedFrags.value.length;return n===0?'АРОМАТ':`${n} АРОМАТ${n>1?'А':''}`})

const psg=computed(()=>({gridTemplateColumns:`repeat(${activePriceCount.value},1fr)`}))

// ── Scroll ──
const scrollTrack=ref(null),thumbTop=ref(0),thumbHeight=ref(10)
const updateThumb=()=>{const wH=window.innerHeight,dH=document.documentElement.scrollHeight,sY=window.scrollY;thumbHeight.value=Math.max((wH/dH)*100,5);const mx=dH-wH;thumbTop.value=mx<=0?0:(sY/mx)*(100-thumbHeight.value)}
const handleDrag=y=>{const tr=scrollTrack.value;if(!tr)return;const r=tr.getBoundingClientRect();const p=Math.min(Math.max((y-r.top)/r.height,0),1);window.scrollTo({top:p*(document.documentElement.scrollHeight-window.innerHeight),behavior:'auto'})}
let isDragging=false
const startDrag=e=>{isDragging=true;handleDrag(e.touches?e.touches[0].clientY:e.clientY);window.addEventListener('mousemove',onMM);window.addEventListener('touchmove',onTM,{passive:false});window.addEventListener('mouseup',stopDrag);window.addEventListener('touchend',stopDrag)}
const onMM=e=>{if(isDragging)handleDrag(e.clientY)},onTM=e=>{if(isDragging){e.preventDefault();handleDrag(e.touches[0].clientY)}}
const stopDrag=()=>{isDragging=false;window.removeEventListener('mousemove',onMM);window.removeEventListener('touchmove',onTM);window.removeEventListener('mouseup',stopDrag);window.removeEventListener('touchend',stopDrag)}
const trackClick=e=>handleDrag(e.clientY)

// ── Data loading ──
const parseCSV=data=>{try{return data.split(/\r?\n/).filter(l=>l.trim()).map(row=>{const c=row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(x=>x.replace(/^"|"$/g,'').trim());if(!c[0]||isNaN(parseInt(c[0]))||!c[2])return null;const g=c[4]?c[4].toLowerCase().trim():'';const fG=(g==='m'||g==='м'||g.includes('муж'))?'m':(g==='w'||g==='ж'||g.includes('жен'))?'w':(g==='y'||g==='у'||g.includes('уни'))?'y':'';const st=c[10]?c[10].trim():'';return{id:c[0],link:c[1]||'',brand:c[2]||'',name:c[3]||'',gender:fG,factory:c[5]||'',quality:c[6]||'',p50:parseInt(c[7])||0,p500:parseInt(c[8])||0,p1000:parseInt(c[9])||0,status:st,hasPlus:st.includes('+'),hasStar:st.includes('*'),isOut:st.includes('-'),sales6m:parseFloat(c[11])||0,salesAll:parseFloat(c[12])||0}}).filter(Boolean)}catch{return[]}}
const loadData=async()=>{loading.value=true;errorMsg.value=null;try{const r=await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');if(!r.ok)throw new Error();products.value=parseCSV(await r.text());if(!products.value.length)throw new Error();setTimeout(()=>loading.value=false,1500)}catch{errorMsg.value='Не удалось подключиться к базе данных.';loading.value=false}}

// ── Computed ──
const uniqueBrands=computed(()=>{const s=new Set();products.value.forEach(p=>p.brand&&s.add(p.brand));return Array.from(s).sort()})
const filteredBrandsDropdown=computed(()=>{const q=tempBrandInput.value.toLowerCase();return q?uniqueBrands.value.filter(b=>b.toLowerCase().includes(q)):uniqueBrands.value})
const uniqueFrags=computed(()=>{const s=new Set();products.value.forEach(p=>p.name&&s.add(p.name));return Array.from(s).sort()})
const filteredFragsDropdown=computed(()=>{const q=tempFragInput.value.toLowerCase();return q?uniqueFrags.value.filter(f=>f.toLowerCase().includes(q)):uniqueFrags.value})

const filteredProducts=computed(()=>products.value.filter(p=>{
  if(selectedBrands.value.length&&!selectedBrands.value.includes(p.brand))return false
  if(selectedFrags.value.length&&!selectedFrags.value.includes(p.name))return false
  if(activeGender.value!=='ВСЕ'&&p.gender!==activeGender.value)return false
  if(activeQuality.value!=='ВСЕ'&&p.quality!==activeQuality.value)return false
  if(activeFactory.value!=='ВСЕ'&&!p.factory.toUpperCase().includes(activeFactory.value))return false
  if(filterPlus.value&&!p.hasPlus)return false
  if(filterStar.value&&!p.hasStar)return false
  if(!showOut.value&&p.isOut)return false
  return true
}))
const sortedProducts=computed(()=>{const l=[...filteredProducts.value];if(sortBy.value==='asc')l.sort((a,b)=>a.p1000-b.p1000);else if(sortBy.value==='desc')l.sort((a,b)=>b.p1000-a.p1000);else l.sort((a,b)=>a.id-b.id);return l})
const stats=computed(()=>{const all=products.value.filter(p=>{if(selectedBrands.value.length&&!selectedBrands.value.includes(p.brand))return false;if(selectedFrags.value.length&&!selectedFrags.value.includes(p.name))return false;if(activeGender.value!=='ВСЕ'&&p.gender!==activeGender.value)return false;if(activeQuality.value!=='ВСЕ'&&p.quality!==activeQuality.value)return false;if(activeFactory.value!=='ВСЕ'&&!p.factory.toUpperCase().includes(activeFactory.value))return false;if(filterPlus.value&&!p.hasPlus)return false;if(filterStar.value&&!p.hasStar)return false;return true});const n=all.length||1;let s50=0,s500=0,s1000=0,av=0,ou=0;const ql={TOP:0,Q1:0,Q2:0},fc={LUZI:0,EPS:0,SELUZ:0};all.forEach(i=>{if(ql[i.quality]!==undefined)ql[i.quality]++;if(!i.isOut)av++;else ou++;s50+=i.p50;s500+=i.p500;s1000+=i.p1000;const f=i.factory.toUpperCase();if(f.includes('LUZI'))fc.LUZI++;else if(f.includes('EPS'))fc.EPS++;else if(f.includes('SELUZ'))fc.SELUZ++});const tl=[...all].sort((a,b)=>statsMode.value==='6m'?b.sales6m-a.sales6m:b.salesAll-a.salesAll).slice(0,50);return{total:all.length,countAvail:av,countOut:ou,availability:Math.round(av/n*100),avg50:Math.round(s50/n),avg500:Math.round(s500/n),avg1000:Math.round(s1000/n),qualityPerc:{TOP:Math.round(ql.TOP/n*100),Q1:Math.round(ql.Q1/n*100),Q2:Math.round(ql.Q2/n*100)},factoryPerc:{LUZI:Math.round(fc.LUZI/n*100),EPS:Math.round(fc.EPS/n*100),SELUZ:Math.round(fc.SELUZ/n*100)},topListFull:tl}})
const getSex=g=>({m:'МУЖ',w:'ЖЕН',y:'УНИ'}[g]||'—')
const openLink=u=>window.open(u.startsWith('http')?u:`https://${u}`,'_blank')

onMounted(()=>{const s=document.createElement('style');s.id='bg';s.textContent='html::-webkit-scrollbar{display:none!important}html{scrollbar-width:none!important;-ms-overflow-style:none!important}';document.head.appendChild(s);let m=document.querySelector('meta[name=viewport]');if(!m){m=document.createElement('meta');m.name='viewport';document.head.appendChild(m)}m.content='width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no';loadData();window.addEventListener('scroll',updateThumb);window.addEventListener('resize',updateThumb);window.addEventListener('resize',recP)})
onUnmounted(()=>{window.removeEventListener('scroll',updateThumb);window.removeEventListener('resize',updateThumb);window.removeEventListener('resize',recP)})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');

*{box-sizing:border-box;-webkit-tap-highlight-color:transparent}
.main-font{font-family:'Nunito',sans-serif}.kollektif{font-family:'Kollektif','Nunito',sans-serif}.mono{font-family:'JetBrains Mono',monospace}.center{display:flex;align-items:center;justify-content:center}
.bahur-terminal{min-height:100vh;background:var(--bg);color:var(--text);font-family:'Nunito',sans-serif;touch-action:pan-y;transition:background .5s ease,color .5s ease}
::-webkit-scrollbar{width:0;height:0}
.container{max-width:1400px;margin:0 auto;padding:8px;overflow-x:hidden}

/* ══ LIQUID GLASS ══ */
.liquid-el{position:relative;isolation:isolate}
.liquid-el::before{content:'';position:absolute;inset:0;z-index:0;border-radius:inherit;box-shadow:inset 0 1px 14px -4px var(--glass-shine);background-color:var(--glass-base);pointer-events:none}
.liquid-el::after{content:'';position:absolute;inset:0;z-index:-1;border-radius:inherit;backdrop-filter:blur(var(--lg-blur,16px)) saturate(1.2);-webkit-backdrop-filter:blur(var(--lg-blur,16px)) saturate(1.2);filter:url(#liquid-glass);-webkit-filter:url(#liquid-glass);isolation:isolate;pointer-events:none}

/* Loading */
.lo{position:fixed;inset:0;background:#000;z-index:9999;display:flex;justify-content:center;align-items:center;overflow:hidden}
.lo-bg{position:absolute;inset:0;background:repeating-linear-gradient(45deg,transparent,transparent 10px,rgba(255,255,255,.15) 10px,rgba(255,255,255,.15) 13px);background-size:200% 200%;animation:bgm 4s linear infinite}
@keyframes bgm{to{background-position:100% 100%}}
.lo-c{position:relative;z-index:10}.lo-t{font-weight:800;font-size:56px;color:#fff;letter-spacing:10px;opacity:0;animation:si 1.5s cubic-bezier(.2,.8,.2,1) forwards}
@keyframes si{0%{transform:scale(.8);opacity:0;filter:blur(10px)}100%{transform:scale(1);opacity:1;filter:blur(0)}}
.ez{display:flex;justify-content:center;align-items:center;height:50vh}.eb{text-align:center;border:1px solid var(--border);padding:40px 60px;border-radius:12px;background:var(--card-bg)}

/* ── Sticky Header ── */
.sn{position:sticky;top:0;z-index:100;background:var(--sticky-bg);border-radius:14px;overflow:visible;padding:6px 8px 4px;transition:background .5s ease;box-shadow:0 4px 20px rgba(0,0,0,.15);border:1px solid var(--glass-brd)}

/* Stats tab */
.stats-tab{position:absolute;top:-1px;left:12px;transform:translateY(-100%);background:var(--card-bg);border:1px solid var(--glass-brd);border-bottom:none;border-radius:6px 6px 0 0;padding:2px 8px;cursor:pointer;color:var(--dim);transition:all .3s ease;z-index:101;line-height:1}
.stats-tab:hover{color:var(--text)}
.stats-tab.active{color:var(--text);background:var(--sticky-bg)}
.stats-arrow{display:inline-block;font-size:10px;transition:transform .3s ease}
.stats-arrow.flip{transform:rotate(180deg)}

/* Dashboard */
.dw{display:grid;grid-template-rows:0fr;transition:grid-template-rows .4s cubic-bezier(.4,0,.2,1)}.dw.open{grid-template-rows:1fr;margin-bottom:6px}.dc{overflow:hidden}
.dg{display:grid;grid-template-columns:repeat(5,1fr);gap:4px}
.sc{border:1px solid var(--border);padding:10px 12px;background:var(--card-bg);border-left:2px solid var(--accent);border-radius:8px;transition:all .4s ease}
.sc-right{text-align:right}.sc-right .bm{justify-content:flex-end}
.sw2{grid-column:span 5}.sl{display:block;font-size:7px;font-weight:800;color:var(--dim);margin-bottom:5px;letter-spacing:1.5px;text-transform:uppercase}
.sv{font-size:15px;font-weight:800}.ss{display:flex;gap:8px;margin-top:4px;font-size:8px;color:var(--dim);font-weight:700}.ss b{color:var(--text);margin-left:2px}
.sp2{display:flex;flex-direction:column;gap:1px}.sp3{font-size:9px;color:var(--dim);font-weight:700}.sp3 span{color:var(--accent);font-weight:800;margin-left:3px}
.br{margin-bottom:3px}.bm{display:flex;justify-content:space-between;font-size:7px;font-weight:700;margin-bottom:2px;text-transform:uppercase}
.bn{height:2px;background:var(--border);border-radius:1px;overflow:hidden}.bt{height:3px;background:var(--border);border-radius:2px;overflow:hidden;margin-top:5px}
.bf{height:100%;background:var(--accent);transition:all .4s ease}
.tsw{background:transparent;border:1px solid var(--border);color:var(--text);padding:3px 10px;border-radius:16px;font-size:8px;font-weight:700;cursor:pointer;transition:all .2s ease}
.tsc{max-height:100px;overflow-y:auto;display:flex;flex-direction:column;gap:2px;scrollbar-width:none}
.tsc::-webkit-scrollbar{width:0}
.tr2{display:grid;grid-template-columns:minmax(0,2fr) auto minmax(0,1fr);align-items:center;gap:6px;padding:2px 0;border-bottom:1px solid var(--border)}.tr2:last-child{border-bottom:none}
.tl{display:flex;align-items:center;min-width:0;overflow:hidden}.tn{color:var(--dim);margin-right:3px;font-weight:700;font-size:8px}
.tname{overflow:hidden;white-space:nowrap;text-overflow:ellipsis;font-weight:700;font-size:9px;text-transform:uppercase}
.tb2{display:flex;gap:2px}.tbd{border:1px solid var(--border);padding:1px 3px;font-size:6px;border-radius:3px;font-weight:700;text-transform:uppercase}.tbh{background:var(--pill-meta);border-color:transparent;font-weight:800}

/* ── Table header ── */
.th{display:grid;grid-template-columns:22px .7fr 1fr repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;padding:0}
.hn{padding:2px;display:flex;align-items:stretch}
.hid{padding:2px;display:flex;align-items:center;justify-content:center}
.hid .hp{width:22px;font-size:7px;justify-content:center;padding:0}
.hpl{padding:2px;display:flex;align-items:stretch;justify-content:center}.hpr{display:grid;padding:2px;gap:2px}.hpr .hpl{padding:0}
.hp{display:flex;align-items:center;justify-content:center;width:100%;height:28px;border-radius:7px;font-size:7px;font-weight:800;letter-spacing:.8px;color:var(--dim);white-space:nowrap;transition:all .3s ease;background:transparent}
.mhp{background:var(--pill-meta)}.php{background:var(--pill-price)}
.nhp{background:transparent;justify-content:center;font-size:8px;letter-spacing:1px}

/* Clickable header — brand/aroma */
.hdr-click{border:none;cursor:pointer;gap:5px;transition:all .25s ease;background:var(--card-bg);color:var(--dim);justify-content:flex-start;padding-left:8px;font-size:8px;letter-spacing:1px}
.hdr-click:hover{background:var(--hover-bg);color:var(--text)}
.hdr-click.active{background:var(--text);color:var(--bg)}
.hdr-click.active .search-ico{color:var(--bg)}
.search-ico{width:11px;height:11px;flex-shrink:0;opacity:.4;transition:opacity .2s}
.hdr-click:hover .search-ico{opacity:.7}

/* ── FAB ── */
.fab-filter{position:fixed;bottom:20px;left:50%;transform:translateX(-50%);z-index:150;display:flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:50%;border:1px solid var(--fab-brd);cursor:pointer;color:var(--text);background:var(--fab-bg);box-shadow:0 4px 16px rgba(0,0,0,.15);transition:all .3s cubic-bezier(.4,0,.2,1)}
.fab-filter.active{transform:translateX(-50%) scale(.9) rotate(90deg)}
.fab-filter:hover{transform:translateX(-50%) scale(1.05);box-shadow:0 6px 24px rgba(0,0,0,.2)}

/* ── Filters ── */
.filter-cascade{position:fixed;inset:0;z-index:9000;display:flex;align-items:flex-end;justify-content:center}
.fc-overlay{position:absolute;inset:0;background:rgba(0,0,0,.35);backdrop-filter:blur(3px);-webkit-backdrop-filter:blur(3px)}
.fc-panel{position:relative;z-index:1;width:100%;max-width:380px;max-height:80vh;overflow-y:auto;border-radius:20px 20px 0 0;padding:12px 16px 24px;display:flex;flex-direction:column;gap:10px;background:var(--panel-bg);border:1px solid var(--border);border-bottom:none;box-shadow:0 -8px 40px rgba(0,0,0,.2);scrollbar-width:none}
.fc-panel::-webkit-scrollbar{width:0}
.fc-handle{width:32px;height:3px;background:var(--dim);opacity:.3;border-radius:3px;margin:0 auto 4px}
.fc-head{display:flex;justify-content:space-between;align-items:center}
.fc-title{font-size:10px;font-weight:800;letter-spacing:2px;color:var(--dim)}
.fc-close{background:transparent;border:none;color:var(--dim);font-size:16px;cursor:pointer;padding:4px 6px;transition:color .2s}.fc-close:hover{color:var(--text)}
.cascade-enter-active{transition:all .35s cubic-bezier(.4,0,.2,1)}.cascade-leave-active{transition:all .25s cubic-bezier(.4,0,.2,1)}
.cascade-enter-from .fc-panel{transform:translateY(100%)}.cascade-leave-to .fc-panel{transform:translateY(100%)}
.cascade-enter-from .fc-overlay{opacity:0}.cascade-leave-to .fc-overlay{opacity:0}

/* Theme toggle */
.theme-toggle{display:flex;align-items:center;gap:10px;justify-content:center;padding:6px 0;cursor:pointer;user-select:none}
.tt-label{font-size:8px;font-weight:800;letter-spacing:1px;color:var(--dim);transition:color .3s}
.tt-label.active{color:var(--text)}
.tt-track{width:38px;height:20px;border-radius:20px;background:var(--seg-bg);border:1px solid var(--border);position:relative;transition:all .35s cubic-bezier(.4,0,.2,1);flex-shrink:0}
.tt-thumb{width:14px;height:14px;border-radius:50%;background:var(--text);position:absolute;left:2px;top:2px;transition:transform .35s cubic-bezier(.4,0,.2,1)}
.tt-track.light .tt-thumb{transform:translateX(18px)}

/* Filter sections */
.ps{padding:0}.pl{display:block;font-size:7px;font-weight:800;color:var(--dim);margin-bottom:4px;letter-spacing:1.5px}
.sg{display:flex;background:var(--seg-bg);padding:2px;border-radius:8px;transition:background .4s ease}
.sgb{flex:1;background:transparent;border:none;color:var(--seg-txt);padding:5px 0;font-size:8px;font-weight:800;border-radius:6px;cursor:pointer;transition:all .2s ease;letter-spacing:.5px;display:flex;align-items:center;justify-content:center;gap:2px}
.sgb.active{background:var(--seg-active);color:var(--seg-txt-active);box-shadow:0 1px 3px rgba(0,0,0,.2)}
.tgr{display:flex;justify-content:space-between;align-items:center;cursor:pointer;padding:6px 0;border-bottom:1px solid var(--border);gap:8px;transition:opacity .2s}.tgr:last-child{border-bottom:none}
.tgr:hover{opacity:.8}
.tgl{font-size:9px;color:var(--text);font-weight:800;display:flex;align-items:center;gap:5px;letter-spacing:.7px}
.tg{width:30px;height:16px;border:1px solid var(--border);border-radius:16px;position:relative;flex-shrink:0;transition:all .3s ease}
.tgt{width:10px;height:10px;background:var(--text);border-radius:50%;position:absolute;left:2px;top:2px;transition:transform .3s cubic-bezier(.4,0,.2,1)}
.tg.on .tgt{transform:translateX(14px)}
.ch{display:inline-flex;align-items:center;justify-content:center;width:14px;height:14px;border-radius:3px;font-size:10px;font-weight:900}
.chp{background:rgba(255,255,255,.06);color:var(--dim)}.chs{background:rgba(255,255,255,.06);color:var(--dim)}.chm{background:rgba(255,255,255,.06);color:var(--dim)}

/* Popups */
.co{position:fixed;top:0;left:0;width:100vw;height:100vh;z-index:98;background:transparent}
.popup-teleport{background:var(--panel-bg);border:1px solid var(--border);border-radius:12px;padding:10px;box-shadow:0 16px 48px rgba(0,0,0,.4);display:flex;flex-direction:column;gap:6px;max-height:calc(100vh - 120px);overflow-y:auto;font-family:'Nunito',sans-serif;transition:all .3s ease}
.pop-enter-active,.pop-leave-active{transition:all .2s cubic-bezier(.4,0,.2,1)}.pop-enter-from,.pop-leave-to{opacity:0;transform:translateY(-4px) scale(.98)}
.pinp{width:100%;background:var(--seg-bg);border:1px solid var(--border);padding:7px 10px;border-radius:7px;color:var(--text);font-size:10px;outline:none;font-weight:700;letter-spacing:.5px;transition:all .3s ease}.pinp::placeholder{opacity:.4;color:var(--dim)}
.bsc{max-height:220px;overflow-y:auto;scrollbar-width:none;display:flex;flex-direction:column;gap:1px}
.bsc::-webkit-scrollbar{width:0}
.bbtn{display:flex;justify-content:space-between;align-items:center;background:transparent;color:var(--text);border:none;padding:7px 8px;border-radius:5px;cursor:pointer;font-size:10px;font-weight:700;width:100%;text-align:left;transition:background .15s ease;letter-spacing:.3px;gap:6px}
.bbtn:hover{background:rgba(128,128,128,.08)}
.ab{font-weight:800;border-bottom:1px solid var(--border);border-radius:0;margin-bottom:2px;padding-bottom:8px}
.btx{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-transform:uppercase}

/* ── Product grid ── */
.gt{display:flex;flex-direction:column;gap:2px;width:100%;min-width:700px;padding-top:4px;padding-bottom:80px}
.row{display:grid;grid-template-columns:22px .7fr 1fr repeat(3,52px) calc(var(--p-cols)*52px);align-items:stretch;width:100%;background:var(--card-bg);border:1px solid var(--card-border);border-radius:10px;position:relative;overflow:hidden;transition:all .25s cubic-bezier(.4,0,.2,1);padding:2px}
.row.cr:hover{transform:translateY(-1px);box-shadow:0 4px 16px rgba(0,0,0,.12);background:var(--hover-bg)}
.rc{display:contents}.cr{cursor:pointer}.out{opacity:.35;filter:grayscale(60%)}

/* ID */
.cid{display:flex;align-items:center;justify-content:center;padding:2px 0}
.id-num{font-size:7px;font-weight:700;color:var(--dim);opacity:.6;display:flex;align-items:center;gap:1px;line-height:1}
.id-st{font-size:8px;font-weight:900}
.st-out{color:var(--dim)}.st-plus{color:var(--dim)}.st-star{color:var(--dim)}

/* Brand — left-aligned */
.cn{display:flex;align-items:stretch;padding:1px}
.cbrand .pn{background:var(--pill-meta);border-radius:8px;padding:5px 8px;width:100%;display:flex;align-items:center;justify-content:flex-start;min-height:32px;transition:all .4s ease}
.pn-brand .bc{font-size:10px;font-weight:700;display:block;text-transform:uppercase;letter-spacing:.8px;text-align:left}

/* Aroma */
.caroma .pn{background:var(--pill-name);border-radius:8px;padding:5px 8px;width:100%;display:flex;flex-direction:column;justify-content:center;min-height:32px;transition:all .4s ease}
.st2{font-weight:700;font-size:10px;line-height:1.2;text-transform:uppercase;letter-spacing:.8px}

/* Meta pills (mobile) */
.mm{display:none;margin-top:3px;gap:2px;align-items:center;flex-wrap:wrap}
.mb{background:var(--pill-meta);border-radius:4px;padding:1px 4px;font-size:6px;font-weight:800;text-transform:uppercase;transition:all .3s ease}

/* Desktop meta */
.cm{display:flex;align-items:stretch;padding:1px}.do{}
.pm{background:var(--pill-meta);border-radius:7px;padding:0 3px;font-size:7px;font-weight:800;width:100%;height:100%;min-height:32px;display:flex;align-items:center;justify-content:center;transition:all .4s ease}

/* ── Prices ── */
.cp{display:grid;gap:2px;padding:1px;align-items:stretch}
.pp{background:var(--pill-price);border:1px solid var(--border);border-radius:7px;padding:0 3px;font-size:9px;font-weight:700;width:100%;min-height:32px;display:flex;align-items:center;justify-content:center;transition:all .4s ease;color:var(--text);gap:0}
.pp-main{font-weight:800;font-size:10px}
.pp-cur{font-size:7px;opacity:.4;margin-left:1px}

/* Scroll track */
.strack{position:fixed;right:3px;top:15px;bottom:15px;width:14px;z-index:200;display:flex;justify-content:center;touch-action:none}
.sthumb{position:absolute;width:2px;background:var(--text);border-radius:2px;opacity:.15;transition:opacity .3s}
.strack:hover .sthumb{opacity:.4}
.strack::before{content:'';position:absolute;top:0;bottom:0;width:1px;background:var(--border);opacity:.5}
.tf{}

/* Card sizes */
.sz-s .row{padding:1px}.sz-s .pn{min-height:26px;padding:3px 6px}.sz-s .st2{font-size:8px}.sz-s .pn-brand .bc{font-size:8px}.sz-s .pp{min-height:26px;font-size:8px}.sz-s .pm{min-height:26px}.sz-s .hp{height:24px}
.sz-l .row{padding:3px}.sz-l .pn{min-height:40px;padding:7px 10px}.sz-l .st2{font-size:13px}.sz-l .pn-brand .bc{font-size:12px}.sz-l .pp{min-height:40px;font-size:11px}.sz-l .pm{min-height:40px}.sz-l .hp{height:34px}

@media(min-width:901px){.dg{grid-template-columns:repeat(5,1fr)}.sw2{grid-column:span 5}}
@media(max-width:900px){
  .strack{display:none!important}
  .dg{grid-template-columns:1fr 1fr}.sw2{grid-column:span 2}
  .sn{margin-left:-8px;margin-right:-8px;padding-left:8px;padding-right:8px;border-radius:0 0 12px 12px}
  .stats-tab{left:20px}
  .gt{min-width:100%}
  .do{display:none!important}
  .mm{display:flex!important}
  .th,.row{grid-template-columns:18px .35fr .65fr calc(var(--p-cols)*34px)}
  .row{padding:1px;border-radius:8px}
  .cn{padding:1px}
  .cbrand .pn{padding:3px 4px;border-radius:6px;min-height:0}
  .pn-brand .bc{font-size:7px;letter-spacing:.5px}
  .caroma .pn{padding:3px 5px;border-radius:6px;min-height:0}
  .st2{font-size:8px}
  .id-num{font-size:6px}
  .mm{margin-top:2px;gap:2px}.mb{padding:1px 3px;font-size:5.5px;border-radius:3px}
  .cp{padding:1px;gap:1px}.pp{font-size:8px;min-height:0;border-radius:5px}
  .hn{padding:1px}.nhp{font-size:7px;border-radius:6px;height:26px}
  .hdr-click{font-size:7px;padding-left:5px;height:26px;border-radius:6px}
  .hpr{padding:1px;gap:1px}.hp{height:26px}
  .fab-filter{bottom:14px;width:40px;height:40px}
  .fc-panel{max-width:100%;border-radius:16px 16px 0 0;padding:10px 14px 20px}
  .sz-s .st2{font-size:7px}
  .sz-l .st2{font-size:11px}
  .sz-l .pn-brand .bc{font-size:9px}
  .sz-l .row{padding:2px}
  .sz-l .caroma .pn{padding:5px 6px}
}
</style>
