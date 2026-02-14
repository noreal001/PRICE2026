<template>
  <div :class="['bahur-terminal', { 'noir': isDark }]" :style="{ '--p-cols': activePriceCount }">
    <div class="container">
      
      <header class="header-manifest">
        <div class="header-inner">
           <button @click="showDash = !showDash" class="header-pill-btn">
             <span class="main-font">СТАТИСТИКА</span>
             <svg :class="['h-icon', { 'closed-arrow': !showDash }]" viewBox="0 0 24 24"><path fill="currentColor" d="M13,9H18.5L13,3.5V9M6,2H14L20,8V20A2,2 0 0,1 18,22H6C4.89,22 4,21.1 4,20V4C4,2.89 4.89,2 6,2M7,20H9V14H7V20M11,20H13V12H11V20M15,20H17V16H15V20Z" /></svg>
           </button>

           <button @click="isDark = !isDark" class="header-pill-btn">
             <span class="main-font">{{ isDark ? 'СВЕТ' : 'ТЬМА' }}</span>
           </button>
        </div>
      </header>

      <div v-if="loading" class="loading-overlay">
         <div class="diagonal-bg"></div>
         <div class="intro-content">
            <span class="intro-text main-font">BAHUR</span>
         </div>
      </div>

      <div v-if="errorMsg" class="error-zone">
        <div class="error-box-noir">
          <div class="err-icon">✕</div>
          <h3 class="err-title mono">ОШИБКА ПОДКЛЮЧЕНИЯ</h3>
          <p class="err-desc">{{ errorMsg }}</p>
          <button @click="loadData" class="retry-btn-noir">ПОВТОРИТЬ</button>
        </div>
      </div>

      <div v-else-if="!loading">
        
        <div :class="['dash-collapsible-wrapper', { 'open': showDash }]">
          <div class="dash-inner-content">
            <section class="dashboard">
              <div class="dash-grid">
                <div class="stat-card span-full">
                  <div class="split-top-row">
                    <div class="st-item">
                      <label class="d-label">АРОМАТЫ</label>
                      <div class="v mono">{{ stats.total }}</div>
                    </div>
                    <div class="st-sep"></div>
                    <div class="st-price-box">
                      <label class="d-label">СРЕДНЯЯ ЦЕНА (1кг)</label>
                      <div class="v mono">{{ stats.avg1000 }}₽</div>
                    </div>
                  </div>
                </div>

                <div class="stat-card span-full">
                  <label class="d-label">НАЛИЧИЕ НА СКЛАДЕ</label>
                  <div class="stock-layout">
                    <div class="stock-big-num mono">{{ stats.availability }}%</div>
                    <div class="stock-right">
                      <div class="q-track-neon-thick">
                        <div class="q-fill-neon-thick" :style="{ width: stats.availability + '%' }"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>

        <div class="table-frame">
          <div class="sticky-nav-group">
            <section class="controls-luxury">
              <div class="ctrl-wrapper-desktop">
                <div class="control-item">
                  <button @click="toggleBrandMenu" :class="['main-ctrl-btn', { 'active-mode': selectedBrands.length > 0 }]">
                    <span class="btn-txt-fixed main-font">{{ brandLabel }}</span>
                  </button>
                  <transition name="pop">
                    <div v-if="showBrandMenu" class="bahur-popup-menu list-mode">
                       <input v-model="tempBrandInput" type="text" placeholder="Поиск..." class="popup-input main-font" />
                       <div class="brands-scroll-area custom-scroll-minimal">
                          <button @click="clearBrands" class="brand-row-btn all-brand-btn">Все</button>
                          <button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="brand-row-btn">
                            {{ b }} <span v-if="selectedBrands.includes(b)">✓</span>
                          </button>
                       </div>
                    </div>
                  </transition>
                </div>

                <div class="control-item">
                  <button @click="toggleNewMenu" :class="['main-ctrl-btn', { 'active-mode': filterPlus || filterStar || showOut }]">
                    <span class="main-font">СТАТУС</span>
                  </button>
                  <transition name="pop">
                    <div v-if="showNewMenu" class="bahur-popup-menu center-mode">
                       <div class="toggle-row" @click="filterPlus = !filterPlus">
                         <span class="toggle-label">Новинки (+)</span>
                         <div :class="['bw-toggle', { 'on': filterPlus }]"><div class="bw-thumb"></div></div>
                       </div>
                       <div class="toggle-row" @click="showOut = !showOut">
                         <span class="toggle-label">Нет в наличии (-)</span>
                         <div :class="['bw-toggle', { 'on': showOut }]"><div class="bw-thumb"></div></div>
                       </div>
                    </div>
                  </transition>
                </div>

                <div class="control-item">
                  <button @click="toggleFilterMenu" :class="['main-ctrl-btn', { 'active-mode': showFilters }]">
                    <span class="main-font">ФИЛЬТР</span>
                  </button>
                  <transition name="pop">
                    <div v-if="showFilters" class="bahur-popup-menu filter-mode">
                      <div class="popup-section">
                        <span class="popup-label">Сортировка</span>
                        <div class="segmented-control">
                          <button v-for="s in sortOptions" :key="s.val" @click="sortBy = s.val" :class="['segment-btn', { active: sortBy === s.val }]">{{ s.label }}</button>
                        </div>
                      </div>
                    </div>
                  </transition>
                </div>
              </div>
              <div v-if="showFilters || showBrandMenu || showNewMenu" class="click-overlay" @click="closeAllMenus"></div>
            </section>

            <div class="grid-layout-def head">
              <div class="cell id head-txt center">№</div>
              <div class="cell name name-header">
                <div class="header-search-container">
                  <input v-model="searchQuery" type="text" placeholder="ПОИСК..." class="header-search-input main-font" />
                </div>
              </div>
              <div class="cell desk-only head-txt center">Пол</div>
              <div class="cell desk-only head-txt center">Фабрика</div>
              <div class="cell desk-only head-txt center">Качество</div>
              <div class="price-section-grid head-p" :style="priceSubGridStyle">
                <div v-if="showPrices.p50" class="p-col center">50г</div>
                <div v-if="showPrices.p500" class="p-col center">500г</div>
                <div v-if="showPrices.p1000" class="p-col center">1кг</div>
              </div>
            </div>
          </div>

          <div class="grid-table">
            <div v-for="(p, index) in sortedProducts" :key="p.id + '-' + index" 
                 :class="['grid-layout-def', 'clickable-row', { 'out': p.isOut, 'simulated-hover': autoHighlightId === p.id }]"
                 @click="p.link && p.link.length > 5 ? open(p.link) : null">
              
              <div class="cell id-zone-square center">
                <div class="id-sq-top mono">{{ p.id }}</div>
                <div class="status-symbol mono">
                  <span v-if="p.isOut" class="sym-minus watermelon-txt">-</span>
                  <span v-else-if="p.hasPlus" class="sym-plus jade-txt">+</span>
                  <span v-else-if="p.hasStar" class="sym-star purple-txt">*</span>
                </div>
              </div>

              <div class="cell name">
                <div class="scent-content">
                  <span class="brand-code main-font">{{ p.brand }}</span>
                  <span class="scent-title main-font">{{ p.name }}</span>
                  <div class="mobile-only-meta">
                    <span class="m-badge">{{ getSex(p.gender) }}</span> 
                    <span class="m-badge">{{ p.factory }}</span> 
                  </div>
                </div>
              </div>

              <div class="cell desk-only center"><div class="badge-pill">{{ getSex(p.gender) }}</div></div>
              <div class="cell desk-only center"><div class="badge-pill">{{ p.factory }}</div></div>
              <div class="cell desk-only center"><div class="badge-pill">{{ p.quality }}</div></div>
              
              <div class="price-container">
                <div class="price-section-grid" :style="priceSubGridStyle">
                  <div v-if="showPrices.p50" class="p-col mono">{{ p.p50 }}₽</div>
                  <div v-if="showPrices.p500" class="p-col mono">{{ p.p500 }}₽</div>
                  <div v-if="showPrices.p1000" class="p-col mono bold">{{ p.p1000 }}₽</div>
                </div>
              </div>

              <div class="row-aura-overlay"><span class="aura-text main-font">ПЕРЕЙТИ</span></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="!loading" class="scroll-widget-track" ref="scrollTrack" @mousedown.prevent="startDrag" @touchstart.prevent="startDrag">
       <div class="scroll-widget-thumb" :style="{ top: thumbTop + '%', height: thumbHeight + '%' }"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

// -- STATE --
const isDark = ref(true); 
const loading = ref(true); 
const errorMsg = ref(null);
const products = ref([]); 
const showDash = ref(false);
const statsMode = ref('6m');
const selectedBrands = ref([]); 
const tempBrandInput = ref('');
const showBrandMenu = ref(false);
const searchQuery = ref('');
const showFilters = ref(false);
const showNewMenu = ref(false);
const filterPlus = ref(false);
const filterStar = ref(false);
const showOut = ref(false); 
const activeGender = ref('ВСЕ'); 
const activeQuality = ref('ВСЕ'); 
const sortBy = ref('id');
const activeFactory = ref('ВСЕ');
const autoHighlightId = ref(null);
const showPrices = ref({ p50: true, p500: true, p1000: true });

// -- CONFIG --
const sortOptions = [{ label: 'ID', val: 'id' }, { label: 'Цена ▲', val: 'asc' }, { label: 'Цена ▼', val: 'desc' }];
const priceSubGridStyle = computed(() => ({ gridTemplateColumns: `repeat(${Object.values(showPrices.value).filter(Boolean).length}, 1fr)` }));
const activePriceCount = computed(() => Object.values(showPrices.value).filter(Boolean).length);
const brandLabel = computed(() => selectedBrands.value.length === 0 ? 'Бренды' : `Бренды: ${selectedBrands.value.length}`);

// -- LOGIC --
const toggleBrandMenu = () => { closeAllMenus(); showBrandMenu.value = !showBrandMenu.value; }
const toggleNewMenu = () => { closeAllMenus(); showNewMenu.value = !showNewMenu.value; }
const toggleFilterMenu = () => { closeAllMenus(); showFilters.value = !showFilters.value; }
const closeAllMenus = () => { showBrandMenu.value = showFilters.value = showNewMenu.value = false; }
const clearBrands = () => { selectedBrands.value = []; closeAllMenus(); }
const toggleBrandSelection = (b) => {
  const idx = selectedBrands.value.indexOf(b);
  if (idx === -1) selectedBrands.value.push(b); else selectedBrands.value.splice(idx, 1);
}

const parseCSV = (data) => {
  const rows = data.split(/\r?\n/).filter(line => line.trim());
  return rows.map(row => {
    const col = row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(c => c.replace(/^"|"$/g, '').trim());
    if (!col[0] || isNaN(parseInt(col[0]))) return null;
    const status = col[10] || '';
    return {
      id: col[0], link: col[1] || '', brand: col[2] || '', name: col[3] || '',
      gender: (col[4] || '').toLowerCase(), factory: col[5] || '', quality: col[6] || '',
      p50: parseInt(col[7]) || 0, p500: parseInt(col[8]) || 0, p1000: parseInt(col[9]) || 0,
      hasPlus: status.includes('+'), hasStar: status.includes('*'), isOut: status.includes('-'),
      sales6m: parseFloat(col[11]) || 0, salesAll: parseFloat(col[12]) || 0
    }
  }).filter(p => p !== null);
}

const loadData = async () => {
  loading.value = true;
  try {
    const res = await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');
    const txt = await res.text();
    products.value = parseCSV(txt);
    setTimeout(() => loading.value = false, 1000);
  } catch (e) { errorMsg.value = "Ошибка загрузки данных"; loading.value = false; }
}

const filteredProducts = computed(() => {
  return products.value.filter(p => {
    if (selectedBrands.value.length && !selectedBrands.value.includes(p.brand)) return false;
    if (searchQuery.value && !p.name.toLowerCase().includes(searchQuery.value.toLowerCase()) && !p.brand.toLowerCase().includes(searchQuery.value.toLowerCase())) return false;
    if (filterPlus.value && !p.hasPlus) return false;
    if (!showOut.value && p.isOut) return false;
    return true;
  });
})

const sortedProducts = computed(() => {
  let list = [...filteredProducts.value];
  if (sortBy.value === 'asc') list.sort((a,b) => a.p1000 - b.p1000);
  else if (sortBy.value === 'desc') list.sort((a,b) => b.p1000 - a.p1000);
  else list.sort((a,b) => a.id - b.id);
  return list;
})

const stats = computed(() => {
  const p = products.value;
  const avail = p.filter(x => !x.isOut).length;
  let total1000 = 0;
  p.forEach(x => total1000 += x.p1000);
  return {
    total: p.length,
    availability: Math.round((avail / p.length) * 100) || 0,
    avg1000: Math.round(total1000 / p.length) || 0
  }
})

// -- UTILS --
const getSex = (g) => ({ m: 'Муж', w: 'Жен', y: 'Уни' }[g] || '—');
const open = (u) => window.open(u.startsWith('http') ? u : `https://${u}`, '_blank');

// -- SCROLL WIDGET --
const thumbTop = ref(0); const thumbHeight = ref(10);
const updateThumb = () => {
  const winH = window.innerHeight; const docH = document.documentElement.scrollHeight;
  const ratio = winH / docH; thumbHeight.value = Math.max(ratio * 100, 5);
  thumbTop.value = (window.scrollY / (docH - winH)) * (100 - thumbHeight.value);
}
const startDrag = (e) => {
  const handle = (pageY) => {
    const docH = document.documentElement.scrollHeight; const winH = window.innerHeight;
    window.scrollTo(0, (pageY / winH) * docH);
  }
  const move = (ev) => handle(ev.touches ? ev.touches[0].clientY : ev.clientY);
  const up = () => { window.removeEventListener('mousemove', move); window.removeEventListener('mouseup', up); };
  window.addEventListener('mousemove', move); window.addEventListener('mouseup', up);
}

onMounted(() => { loadData(); window.addEventListener('scroll', updateThumb); });
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;900&family=JetBrains+Mono:wght@400;700&display=swap');

.main-font { font-family: 'Nunito', sans-serif; }
.mono { font-family: 'JetBrains Mono', monospace; }

.bahur-terminal {
  --bg: #111112; --text: #fff; --border: rgba(255,255,255,0.08);
  --card-bg: #19191b; --panel-bg: #121214;
  background: var(--bg); color: var(--text); min-height: 100vh;
}
.noir:not(.noir) { /* Light theme placeholder */ }

.container { max-width: 1400px; margin: 0 auto; padding: 15px; }

/* TABLE CORE */
.grid-layout-def {
  display: grid;
  grid-template-columns: 60px 1fr 80px 100px 100px calc(var(--p-cols) * 90px);
  align-items: stretch;
}

.grid-table { display: flex; flex-direction: column; gap: 8px; padding-top: 10px; }

.grid-layout-def:not(.head) {
  background: var(--card-bg);
  border: 1px solid var(--border);
  border-radius: 16px;
  overflow: hidden;
  transition: 0.2s;
}

.cell { padding: 15px; display: flex; align-items: center; border-right: 1px solid var(--border); }
.cell:last-child { border-right: none; }
.center { justify-content: center; text-align: center; }

/* MOBILE SYMMETRY FIX */
@media (max-width: 900px) {
  .grid-layout-def {
    grid-template-columns: 50px 1fr calc(var(--p-cols) * 65px) !important;
  }
  .desk-only { display: none; }
  .cell { padding: 10px 5px; }
  .scent-title { font-size: 14px; font-weight: 700; }
  .brand-code { font-size: 9px; opacity: 0.6; }
  
  .price-container { border-left: 1px solid var(--border); }
  .p-col { border-right: 1px solid var(--border); font-size: 12px; height: 100%; display: flex; align-items: center; justify-content: center;}
  .p-col:last-child { border-right: none; }
  
  .id-zone-square { border-right: 1px solid var(--border); flex-direction: column; }
}

/* UI ELEMENTS */
.header-inner { display: flex; justify-content: space-between; border-bottom: 1px solid var(--border); padding-bottom: 15px; }
.header-pill-btn { background: transparent; border: 1px solid var(--border); color: #fff; border-radius: 20px; padding: 8px 15px; cursor: pointer; }

.main-ctrl-btn { width: 100%; background: var(--card-bg); border: 1px solid var(--border); color: #fff; padding: 12px; border-radius: 12px; font-weight: 700; cursor: pointer; }
.main-ctrl-btn.active-mode { background: #fff; color: #000; }

.sticky-nav-group { position: sticky; top: 0; z-index: 100; background: rgba(17,17,18,0.9); backdrop-filter: blur(10px); }
.ctrl-wrapper-desktop { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; padding: 15px 0; }

.price-section-grid { display: grid; height: 100%; width: 100%; }
.badge-pill { background: rgba(255,255,255,0.05); padding: 4px 10px; border-radius: 8px; font-size: 11px; }

/* ANIMATIONS & OVERLAYS */
.loading-overlay { position: fixed; inset: 0; background: #000; z-index: 1000; display: flex; justify-content: center; align-items: center; }
.intro-text { font-size: 40px; font-weight: 900; letter-spacing: 10px; }

.row-aura-overlay { position: absolute; inset: 0; background: rgba(255,255,255,0.03); opacity: 0; display: flex; align-items: center; justify-content: center; pointer-events: none; transition: 0.3s; }
.clickable-row:hover .row-aura-overlay { opacity: 1; }

.scroll-widget-track { position: fixed; right: 4px; top: 20px; bottom: 20px; width: 4px; background: rgba(255,255,255,0.03); }
.scroll-widget-thumb { width: 100%; background: #fff; border-radius: 10px; position: absolute; }

.bahur-popup-menu { position: absolute; top: 100%; background: #19191b; border: 1px solid #333; border-radius: 12px; padding: 15px; z-index: 200; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
.click-overlay { position: fixed; inset: 0; z-index: 150; }
</style>
