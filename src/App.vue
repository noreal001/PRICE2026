Ниже обновлённый `App.vue` с учётом замечаний: выровнял сетку и заголовки, добавил центральные отступы, поправил позицию кнопок/меню, сделал бренд‑меню видимым и на десктопе и на мобиле, приблизил кнопку «Свет», убрал лишние квадраты в статусе, добавил пульсирующий логотип в шапке. Таблица и контролы центрированы, отступы по краям уменьшены.

```vue
<template>
  <div :class="['bahur-terminal', { 'noir': isDark }]" :style="{ '--p-cols': activePriceCount }">
    <div class="container">
      
      <header class="header-manifest">
        <div class="header-inner">
          <div class="logo-pulse">
            <span class="logo-dot"></span>
            <span class="logo-ring"></span>
          </div>
          <button @click="showDash = !showDash" class="header-pill-btn">
            <span class="main-font" style="letter-spacing: 0.5px;">Статистика</span>
          </button>
          <button @click="isDark = !isDark" class="header-pill-btn">
            <span class="main-font" style="letter-spacing: 0.5px;">{{ isDark ? 'Свет' : 'Тьма' }}</span>
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
          <div class="err-action">
             <button @click="loadData" class="retry-btn-noir"><span class="btn-text">ПОВТОРИТЬ</span></button>
          </div>
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
                        <div class="stock-stack-info">
                           <div class="ss-row">Есть: <span class="mono">{{ stats.countAvail }}</span></div>
                           <div class="ss-row">Нет: <span class="mono">{{ stats.countOut }}</span></div>
                        </div>
                     </div>
                     <div <="" class="st-sep"></div>
                     <div class="st-price-box">
                        <label class="d-label">СРЕДНЯЯ ЦЕНА</label>
                        <div class="avg-price-flex">
                           <div v-if="showPrices.p50" class="ap-item">50г:<span class="val">{{ stats.avg50 }}₽</span></div>
                           <div v-if="showPrices.p500" class="ap-item">500г:<span class="val">{{ stats.avg500 }}₽</span></div>
                           <div v-if="showPrices.p1000" class="ap-item">1кг:<span class="val">{{ stats.avg1000 }}₽</span></div>
                        </div>
                     </div>
                  </div>
                </div>

                <div class="stat-card span-full">
                   <div class="stock-layout">
                      <div class="stock-left">
                         <label class="d-label">СКЛАД</label>
                         <div class="stock-big-num mono">{{ stats.availability }}%</div>
                      </div>
                      <div class="stock-right">
                         <div class="q-track-neon-thick">
                            <div class="q-fill-neon-thick white-part" :style="{ width: stats.availability + '%' }"></div>
                         </div>
                         <div class="stock-missing-text">Отсутствует: {{ 100 - stats.availability }}%</div>
                      </div>
                   </div>
                </div>

                <div class="stat-card">
                  <label class="d-label">ФАБРИКИ</label>
                  <div class="q-list">
                    <div v-for="f in ['Luzi', 'Eps', 'Seluz']" :key="f" class="q-row-stacked">
                      <div class="q-meta">
                        <span class="mono">{{ f }}</span>
                        <span class="mono op-5">{{ stats.factoryPerc[f.toUpperCase()] }}%</span>
                      </div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.factoryPerc[f.toUpperCase()] + '%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card">
                  <label class="d-label">КАЧЕСТВО</label>
                  <div class="q-list">
                    <div v-for="q in ['Top', 'Q1', 'Q2']" :key="q" class="q-row-stacked">
                      <div class="q-meta">
                        <span class="mono">{{ q }}</span>
                        <span class="mono op-5">{{ stats.qualityPerc[q.toUpperCase()] }}%</span>
                      </div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.qualityPerc[q.toUpperCase()] + '%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card span-full">
                  <div class="top-header-center">
                    <button @click="toggleStatsMode" class="top-switch-btn-subtle main-font">
                       <span class="btn-subtle-label">РЕЙТИНГ:</span> {{ statsMode === '6m' ? '6 МЕС' : 'ВСЕ ВРЕМЯ' }} 
                       <span class="arrow-indicator">⇄</span>
                    </button>
                  </div>
                  <div class="top-list-scroll-container">
                     <div v-for="(item, idx) in stats.topListFull" :key="idx" class="top-row-compact">
                        <div class="tr-left-main">
                           <span class="top-num mono">{{ idx + 1 }}.</span>
                           <span class="top-name kollektif" :title="item.name">{{ item.name }}</span>
                        </div>
                        <div class="tr-mid-graph">
                           <div class="mini-bar-track">
                             <div class="mini-bar-fill" :style="{ width: (statsMode === '6m' ? item.sales6m : item.salesAll) + '%' }"></div>
                           </div>
                        </div>
                        <div class="tr-right-meta">
                           <div class="badge-mini">{{ item.factory }}</div>
                           <div class="badge-mini">{{ item.quality }}</div>
                           <span class="top-val mono">{{ statsMode === '6m' ? item.sales6m : item.salesAll }}%</span>
                        </div>
                     </div>
                     <div v-if="stats.topListFull.length === 0" class="op-5 mono" style="font-size: 10px;">НЕТ ДАННЫХ</div>
                  </div>
                </div>

              </div>
            </section>
          </div>
        </div>

        <div class="table-frame">
          <div v-if="showFilters || showBrandMenu || showNewMenu" class="click-overlay" @click="closeAllMenus"></div>

          <div class="sticky-nav-group">
            <section class="controls-luxury">
              <div class="ctrl-scroll-row">
                <div class="ctrl-inner-flex">

                  <div class="control-item">
                     <button @click="toggleBrandMenu" :class="['main-ctrl-btn', { 'active-mode': showBrandMenu || selectedBrands.length > 0 }]">
                        <span class="btn-txt-fixed main-font ctrl-text-bold">{{ brandLabel }}</span>
                        <svg class="pill-arrow" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10L7.41 8.59Z"/></svg>
                     </button>
                     <transition name="pop">
                        <div v-if="showBrandMenu" class="bahur-popup-menu list-mode">
                           <div class="search-input-box">
                              <input v-model="tempBrandInput" type="text" inputmode="search" placeholder="Поиск бренда..." class="popup-input main-font" />
                           </div>
                           <div class="brands-scroll-area custom-scroll-minimal">
                              <div class="brands-list-vertical">
                                <button @click="clearBrands" class="brand-row-btn main-font all-brand-btn">
                                  <div class="brand-left-group">
                                     <svg class="circle-check-icon left" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z" /></svg>
                                     <span>Все</span>
                                  </div>
                                </button>
                                <button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="brand-row-btn main-font brand-font-fix">
                                  <div class="brand-left-group"><span class="brand-txt-truncate">{{ b }}</span></div>
                                  <svg v-if="selectedBrands.includes(b)" class="check-status right" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z" /></svg>
                                </button>
                                <div v-if="filteredBrandsDropdown.length === 0" class="no-results main-font">Нет совпадений</div>
                              </div>
                           </div>
                        </div>
                     </transition>
                  </div>

                  <div class="control-item">
                    <button @click="toggleNewMenu" :class="['main-ctrl-btn', { 'active-mode': showNewMenu || filterPlus || filterStar || showOut }]">
                       <span class="main-font ctrl-text-bold">Статус</span>
                       <svg class="pill-arrow" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10L7.41 8.59Z"/></svg>
                    </button>
                    <transition name="pop">
                      <div v-if="showNewMenu" class="bahur-popup-menu center-mode">
                         <div class="toggle-row" @click="filterPlus = !filterPlus">
                           <span class="toggle-label main-font">Новинки <span class="status-chip chip-plus">+</span></span>
                           <div :class="['bw-toggle', { 'on': filterPlus }]"><div class="bw-thumb"></div></div>
                         </div>
                         <div class="toggle-row" @click="filterStar = !filterStar">
                           <span class="toggle-label main-font">Версии <span class="status-chip chip-star">*</span></span>
                           <div :class="['bw-toggle', { 'on': filterStar }]"><div class="bw-thumb"></div></div>
                         </div>
                         <div class="toggle-row" @click="showOut = !showOut">
                           <span class="toggle-label main-font">Нет <span class="status-chip chip-minus">-</span></span>
                           <div :class="['bw-toggle', { 'on': showOut }]"><div class="bw-thumb"></div></div>
                         </div>
                      </div>
                    </transition>
                  </div>

                  <div class="control-item">
                    <button @click="toggleFilterMenu" :class="['main-ctrl-btn', { 'active-mode': showFilters }]">
                      <span class="main-font ctrl-text-bold">{{ showFilters ? 'Закрыть' : 'Фильтр' }}</span>
                      <svg class="pill-arrow" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10L7.41 8.59Z"/></svg>
                    </button>
                     <transition name="pop">
                      <div v-if="showFilters" class="bahur-popup-menu filter-mode">
                        <div class="popup-section">
                          <span class="popup-label main-font">Пол</span>
                          <div class="segmented-control">
                            <button v-for="g in genderOptions" :key="g.val" @click="activeGender = g.val" :class="['segment-btn', { active: activeGender === g.val }]"><span class="main-font">{{ g.label }}</span></button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label main-font">Фабрика</span>
                          <div class="segmented-control">
                            <button v-for="f in factoryOptions" :key="f.val" @click="activeFactory = f.val" :class="['segment-btn', { active: activeFactory === f.val }]"><span class="main-font">{{ f.label }}</span></button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label main-font">Качество</span>
                          <div class="segmented-control">
                            <button v-for="q in qualityOptions" :key="q.val" @click="activeQuality = q.val" :class="['segment-btn', { active: activeQuality === q.val }]"><span class="main-font">{{ q.label }}</span></button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label main-font">Цена</span>
                          <div class="segmented-control">
                            <button v-for="s in sortOptions" :key="s.val" @click="sortBy = s.val" :class="['segment-btn', { active: sortBy === s.val }]">
                               <span v-if="s.val === 'id'" class="main-font">ID</span>
                               <span v-else class="arrows-horn"><b>{{ s.label }}</b>{{ s.val === 'asc' ? '▲' : '▼' }}</span>
                            </button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label main-font">Столбцы</span>
                          <div class="segmented-control">
                            <button v-for="(val, key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['segment-btn', { active: showPrices[key] }]"><span class="main-font">{{ val }}</span></button>
                          </div>
                        </div>
                      </div>
                    </transition>
                  </div>

                </div>
              </div>
            </section>

            <div class="grid-layout-def head no-click">
              <div class="cell id head-txt center">№</div>
              <div class="cell name search-cell-dark">
                 <div class="header-search-container">
                    <svg class="search-icon" viewBox="0 0 24 24"><path fill="currentColor" d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z" /></svg>
                    <input v-model="searchQuery" type="text" placeholder="АРОМАТЫ / ПОИСК..." class="header-search-input main-font" />
                    <button v-if="searchQuery" @click="searchQuery = ''" class="clear-search">✕</button>
                 </div>
              </div>
              <div class="cell desk-only center head-meta-cell"><span class="head-meta-pill">Пол</span></div>
              <div class="cell desk-only center head-meta-cell"><span class="head-meta-pill">Фабрика</span></div>
              <div class="cell desk-only center head-meta-cell"><span class="head-meta-pill">Качество</span></div>
              <div class="price-section head-p" :style="priceSubGridStyle">
                <div v-if="showPrices.p50" class="p-col center"><span class="head-price-pill">50г</span></div>
                <div v-if="showPrices.p500" class="p-col center"><span class="head-price-pill">500г</span></div>
                <div v-if="showPrices.p1000" class="p-col center"><span class="head-price-pill">1кг</span></div>
              </div>
            </div>
          </div>

          <div class="grid-table">
            <div v-for="(p, index) in sortedProducts" :key="p.id + '-' + index" 
                 :class="['grid-layout-def', 'clickable-row', { 'out': p.isOut, 'simulated-hover': autoHighlightId === p.id }]"
                 @click="p.link && p.link.length > 5 ? open(p.link) : null">
              <div class="row-visual-layer">
                
                <div class="cell id-zone-square center">
                  <div class="id-sq-top mono">{{ p.id }}</div>
                  <div class="status-symbol mono">
                    <span v-if="p.isOut" class="sym-minus watermelon-txt">-</span>
                    <span v-else-if="p.hasPlus" class="sym-plus jade-txt">+</span>
                    <span v-else-if="p.hasStar" class="sym-star purple-txt">*</span>
                  </div>
                </div>

                <div class="cell name">
                  <div class="inner-pill-main">
                    <span class="brand-code kollektif">{{ p.brand }}</span>
                    <span class="scent-title kollektif">{{ p.name }}</span>
                    <div class="mobile-only-meta">
                      <span class="inner-pill-badge-mobile kollektif">{{ getSex(p.gender) }}</span> 
                      <span class="inner-pill-badge-mobile kollektif">{{ p.factory }}</span> 
                      <span class="inner-pill-badge-mobile kollektif">{{ p.quality }}</span>
                    </div>
                  </div>
                </div>

                <div class="cell desk-only center"><div class="inner-pill-badge meta-badge kollektif">{{ getSex(p.gender) }}</div></div>
                <div class="cell desk-only center"><div class="inner-pill-badge meta-badge kollektif">{{ p.factory }}</div></div>
                <div class="cell desk-only center"><div class="inner-pill-badge meta-badge kollektif">{{ p.quality }}</div></div>
                
                <div class="price-container">
                  <div class="price-section" :style="priceSubGridStyle">
                    <div v-if="showPrices.p50" class="inner-pill-price mono">{{ p.p50 }}₽</div>
                    <div v-if="showPrices.p500" class="inner-pill-price mono">{{ p.p500 }}₽</div>
                    <div v-if="showPrices.p1000" class="inner-pill-price mono bold">{{ p.p1000 }}₽</div>
                  </div>
                </div>

              </div>
              <div class="row-aura-overlay">
                <svg class="liquid-filter" style="position:absolute;width:0;height:0">
                  <defs>
                    <filter id="liquid-eye" x="-20%" y="-20%" width="140%" height="140%">
                      <feTurbulence type="fractalNoise" baseFrequency="0.015 0.015" numOctaves="2" seed="2" result="noise">
                        <animate attributeName="baseFrequency" values="0.015 0.015;0.025 0.02;0.015 0.015" dur="3s" repeatCount="indefinite"/>
                      </feTurbulence>
                      <feDisplacementMap in="SourceGraphic" in2="noise" scale="8" xChannelSelector="R" yChannelSelector="G"/>
                    </filter>
                  </defs>
                </svg>
                <span class="aura-text kollektif">ПЕРЕЙТИ К АРОМАТУ</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="!loading && !errorMsg" class="scroll-widget-track" ref="scrollTrack" 
         @mousedown.prevent="startDrag" @touchstart.prevent="startDrag" @click="trackClick">
       <div class="scroll-widget-thumb" :style="{ top: thumbTop + '%', height: thumbHeight + '%' }"></div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const isDark = ref(true); 
const loading = ref(true); 
const errorMsg = ref(null);
const products = ref([]); 
const showDash = ref(false);
const statsMode = ref('6m'); 
const toggleStatsMode = () => statsMode.value = statsMode.value === '6m' ? 'all' : '6m';
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
let highlightInterval = null;

const showPrices = ref({ p50: true, p500: true, p1000: true });
const priceLabels = { p50: '50г', p500: '500г', p1000: '1кг' };
const activePriceCount = computed(() => Object.values(showPrices.value).filter(Boolean).length);

const genderOptions = [{ label: 'Все', val: 'ВСЕ' }, { label: 'Муж', val: 'm' }, { label: 'Жен', val: 'w' }, { label: 'Уни', val: 'y' }];
const factoryOptions = [{ label: 'Все', val: 'ВСЕ' }, { label: 'Luzi', val: 'LUZI' }, { label: 'Eps', val: 'EPS' }, { label: 'Seluz', val: 'SELUZ' }];
const qualityOptions = [{ label: 'Все', val: 'ВСЕ' }, { label: 'Top', val: 'TOP' }, { label: 'Q1', val: 'Q1' }, { label: 'Q2', val: 'Q2' }];
const sortOptions = [{ label: 'ID', val: 'id' }, { label: 'Цена', val: 'asc' }, { label: 'Цена', val: 'desc' }];

const togglePrice = (key) => {
  const activeKeys = Object.values(showPrices.value).filter(Boolean);
  if (showPrices.value[key] && activeKeys.length === 1) return;
  showPrices.value[key] = !showPrices.value[key];
}

const toggleFilterMenu = () => { if (showFilters.value) { closeAllMenus(); return; } closeAllMenus(); showFilters.value = true; }
const toggleNewMenu = () => { if (showNewMenu.value) { closeAllMenus(); return; } closeAllMenus(); showNewMenu.value = true; }
const toggleBrandMenu = () => { 
  if (showBrandMenu.value) { closeAllMenus(); return; } 
  closeAllMenus(); showBrandMenu.value = true; tempBrandInput.value = ''; 
}
const toggleBrandSelection = (b) => {
  const idx = selectedBrands.value.indexOf(b);
  if (idx === -1) selectedBrands.value.push(b); else selectedBrands.value.splice(idx, 1);
  closeAllMenus();
}
const clearBrands = () => { selectedBrands.value = []; closeAllMenus(); }
const closeAllMenus = () => { showFilters.value = false; showBrandMenu.value = false; showNewMenu.value = false; }

const brandLabel = computed(() => { 
  const len = selectedBrands.value.length; 
  if (len === 0) return 'Бренды'; 
  return `${len} Бренд${len > 1 ? 'а' : ''}`; 
});
const priceSubGridStyle = computed(() => ({ gridTemplateColumns: `repeat(${activePriceCount.value}, 1fr)` }));

const scrollTrack = ref(null);
const thumbTop = ref(0);
const thumbHeight = ref(10); 
const updateThumb = () => {
  const winH = window.innerHeight;
  const docH = document.documentElement.scrollHeight;
  const scrollY = window.scrollY;
  const ratio = winH / docH;
  thumbHeight.value = Math.max(ratio * 100, 5); 
  const maxScroll = docH - winH;
  if (maxScroll <= 0) { thumbTop.value = 0; return; }
  thumbTop.value = (scrollY / maxScroll) * (100 - thumbHeight.value);
}
const handleDrag = (clientY) => {
  const track = scrollTrack.value; if (!track) return;
  const rect = track.getBoundingClientRect();
  const percent = Math.min(Math.max((clientY - rect.top) / rect.height, 0), 1);
  window.scrollTo({ top: percent * (document.documentElement.scrollHeight - window.innerHeight), behavior: 'auto' });
}
let isDragging = false;
const startDrag = (e) => {
  isDragging = true;
  handleDrag(e.touches ? e.touches[0].clientY : e.clientY);
  window.addEventListener('mousemove', onMouseMove);
  window.addEventListener('touchmove', onTouchMove, { passive: false });
  window.addEventListener('mouseup', stopDrag);
  window.addEventListener('touchend', stopDrag);
}
const onMouseMove = (e) => { if(isDragging) handleDrag(e.clientY); }
const onTouchMove = (e) => { if(isDragging) { e.preventDefault(); handleDrag(e.touches[0].clientY); } }
const stopDrag = () => {
  isDragging = false;
  window.removeEventListener('mousemove', onMouseMove);
  window.removeEventListener('touchmove', onTouchMove);
  window.removeEventListener('mouseup', stopDrag);
  window.removeEventListener('touchend', stopDrag);
}
const trackClick = (e) => handleDrag(e.clientY);

const parseCSV = (data) => {
  try {
    const rows = data.split(/\r?\n/).filter(line => line.trim());
    return rows.map((row) => {
      const col = row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(c => c.replace(/^"|"$/g, '').trim());
      if (!col[0] || isNaN(parseInt(col[0])) || !col[2]) return null;
      let g = col[4] ? col[4].toLowerCase().trim() : '';
      let fG = (g === 'm' || g === 'м' || g.includes('муж')) ? 'm' : (g === 'w' || g === 'ж' || g.includes('жен')) ? 'w' : (g === 'y' || g === 'у' || g.includes('уни')) ? 'y' : '';
      const statusCol = col[10] ? col[10].trim() : '';
      return { 
        id: col[0], link: col[1] || '', brand: col[2] || '', name: col[3] || '', gender: fG, 
        factory: col[5] || '', quality: col[6] || '', p50: parseInt(col[7]) || 0, 
        p500: parseInt(col[8]) || 0, p1000: parseInt(col[9]) || 0, 
        status: statusCol, hasPlus: statusCol.includes('+'), hasStar: statusCol.includes('*'), isOut: statusCol.includes('-'),
        sales6m: parseFloat(col[11]) || 0, salesAll: parseFloat(col[12]) || 0 
      }
    }).filter(p => p !== null);
  } catch(err) { console.error("CSV Parse Error", err); return []; }
}

const loadData = async () => {
  loading.value = true; errorMsg.value = null;
  try {
    const res = await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');
    if (!res.ok) throw new Error('Ошибка сети');
    const txt = await res.text();
    products.value = parseCSV(txt);
    if (products.value.length === 0) throw new Error('Данные пусты или ошибка формата');
    startAutoHighlight();
    setTimeout(() => loading.value = false, 1500);
  } catch (e) { errorMsg.value = "Не удалось подключиться к базе данных."; loading.value = false; }
}

const startAutoHighlight = () => {
  if (highlightInterval) clearInterval(highlightInterval);
  highlightInterval = setInterval(() => {
    if (sortedProducts.value.length > 0) {
      const product = sortedProducts.value[Math.floor(Math.random() * sortedProducts.value.length)];
      if (product) { autoHighlightId.value = product.id; setTimeout(() => { autoHighlightId.value = null; }, 2000); }
    }
  }, 5000);
}

const uniqueBrands = computed(() => { const b = new Set(); products.value.forEach(p => { if(p.brand) b.add(p.brand); }); return Array.from(b).sort(); });
const filteredBrandsDropdown = computed(() => { const s = tempBrandInput.value.toLowerCase(); if (!s) return uniqueBrands.value; return uniqueBrands.value.filter(b => b.toLowerCase().includes(s)); });

const filteredProducts = computed(() => products.value.filter(p => {
  const matchesBrand = selectedBrands.value.length === 0 || selectedBrands.value.includes(p.brand);
  const searchLow = searchQuery.value.toLowerCase();
  const matchesSearch = !searchLow || p.name.toLowerCase().includes(searchLow) || p.brand.toLowerCase().includes(searchLow);
  const matchesGender = activeGender.value === 'ВСЕ' || p.gender === activeGender.value;
  const matchesQuality = activeQuality.value === 'ВСЕ' || p.quality === activeQuality.value;
  const matchesFactory = activeFactory.value === 'ВСЕ' || p.factory.toUpperCase().includes(activeFactory.value);
  if (filterPlus.value && !p.hasPlus) return false;
  if (filterStar.value && !p.hasStar) return false;
  if (!showOut.value && p.isOut) return false; 
  return matchesBrand && matchesSearch && matchesGender && matchesQuality && matchesFactory;
}))

const sortedProducts = computed(() => {
  let list = [...filteredProducts.value];
  if (sortBy.value === 'asc') list.sort((a,b) => a.p1000 - b.p1000);
  else if (sortBy.value === 'desc') list.sort((a,b) => b.p1000 - a.p1000);
  else list.sort((a,b) => a.id - b.id);
  return list;
})

const stats = computed(() => {
  const p = filteredProducts.value; const count = p.length || 1;
  let s50 = 0, s500 = 0, s1000 = 0, avail = 0, out = 0;
  const qual = { 'TOP': 0, 'Q1': 0, 'Q2': 0 };
  const factories = { 'LUZI': 0, 'EPS': 0, 'SELUZ': 0 };
  p.forEach(i => {
    if (qual[i.quality] !== undefined) qual[i.quality]++;
    if (!i.isOut) avail++; else out++;
    s50 += i.p50; s500 += i.p500; s1000 += i.p1000;
    const f = i.factory.toUpperCase();
    if (f.includes('LUZI')) factories['LUZI']++; else if (f.includes('EPS')) factories['EPS']++; else if (f.includes('SELUZ')) factories['SELUZ']++;
  });
  const topListFull = [...p].sort((a,b) => { 
    const vA = statsMode.value === '6m' ? a.sales6m : a.salesAll; 
    const vB = statsMode.value === '6m' ? b.sales6m : b.salesAll; 
    return vB - vA; 
  }).slice(0, 50);
  return { 
    total: p.length, countAvail: avail, countOut: out, availability: Math.round((avail/count)*100),
    avg50: Math.round(s50/count), avg500: Math.round(s500/count), avg1000: Math.round(s1000/count), 
    qualityPerc: { 'TOP': Math.round((qual['TOP']/count)*100), 'Q1': Math.round((qual['Q1']/count)*100), 'Q2': Math.round((qual['Q2']/count)*100) },
    factoryPerc: { 'LUZI': Math.round((factories['LUZI']/count)*100), 'EPS': Math.round((factories['EPS']/count)*100), 'SELUZ': Math.round((factories['SELUZ']/count)*100) },
    topListFull
  }
})

const getSex = (g) => ({ m: 'МУЖ', w: 'ЖЕН', y: 'УНИ' }[g] || '—');
const open = (u) => window.open(u.startsWith('http') ? u : `https://${u}`, '_blank');

onMounted(() => {
  document.documentElement.style.scrollbarWidth = 'none';
  document.documentElement.style.overflow = 'hidden';
  document.documentElement.style.overflow = 'auto';
  const styleEl = document.createElement('style');
  styleEl.textContent = 'html::-webkit-scrollbar { display: none !important; } html { scrollbar-width: none !important; -ms-overflow-style: none !important; }';
  document.head.appendChild(styleEl);

  let meta = document.querySelector('meta[name=viewport]');
  if (!meta) { meta = document.createElement('meta'); meta.name = 'viewport'; document.head.appendChild(meta); }
  meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no";
  const script = document.createElement('script');
  script.src = "https://telegram.org/js/telegram-web-app.js";
  document.head.appendChild(script);
  loadData();
  window.addEventListener('scroll', updateThumb);
  window.addEventListener('resize', updateThumb);
});
onUnmounted(() => { 
  if (highlightInterval) clearInterval(highlightInterval); 
  window.removeEventListener('scroll', updateThumb);
  window.removeEventListener('resize', updateThumb);
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap');
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@100;300;400;700&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Kollektif&display=swap');

.main-font { font-family: 'Nunito', sans-serif; }
.kollektif { font-family: 'Kollektif', 'Nunito', sans-serif; }
.mono { font-family: 'JetBrains Mono', monospace; }

/* ─── ТЕМЫ и размеры ─────────────────────────── */
.bahur-terminal {
  --bg: #19191b; 
  --text: #fff; --border: rgba(255,255,255,0.06); --dim: #555;
  --panel-bg: #111113; 
  --card-bg: #111113;
  --card-border: rgba(255,255,255,0.04);
  --inner-pill-dark: #0b0b0d;
  --inner-pill-name: #161618;
  --inner-pill-meta: #1e1e22;
  --search-pill-bg: #0d0d0f;
  --liquid-bg: rgba(255,255,255,0.06);
  --liquid-border: rgba(255,255,255,0.12);
  --aura-text: #fff;
  --hover-bg: #17171a;
  --sticky-bg: rgba(15,15,17,0.98);
  --seg-bg: #0a0a0c;
  --seg-active: #fff; --seg-txt: #444; --seg-txt-active: #000;
  --btn-ctrl-bg: #111113;
  --btn-ctrl-border: rgba(255,255,255,0.07);
  --col-id: 52px;
  --col-meta: 82px;
  --col-price: 82px;
  transition: background 0s, color 0s;
  min-height: 100vh; background: var(--bg); color: var(--text); font-family: 'Nunito', sans-serif;
  touch-action: pan-y;
}
.noir { 
  --bg: #19191b; --text: #fff; --border: rgba(255,255,255,0.06); --dim: #555;
  --panel-bg: #111113; --card-bg: #111113; --card-border: rgba(255,255,255,0.04);
  --inner-pill-dark: #0b0b0d; --inner-pill-name: #161618; --inner-pill-meta: #1e1e22;
  --search-pill-bg: #0d0d0f;
  --liquid-bg: rgba(255,255,255,0.06); --liquid-border: rgba(255,255,255,0.12);
  --aura-text: #fff; --hover-bg: #17171a;
  --sticky-bg: rgba(15,15,17,0.98);
  --seg-bg: #0a0a0c; --seg-active: #fff; --seg-txt: #444; --seg-txt-active: #000;
  --btn-ctrl-bg: #111113; --btn-ctrl-border: rgba(255,255,255,0.07);
}
.bahur-terminal:not(.noir) { 
  --bg: #f0f0f4; --text: #0f0f11; --border: rgba(0,0,0,0.07); --dim: #aaa;
  --panel-bg: #fafafa; --card-bg: #fafafa; --card-border: rgba(0,0,0,0.05);
  --inner-pill-dark: #e3e3eb;
  --inner-pill-name: #eaeaf0;
  --inner-pill-meta: #dddde6;
  --search-pill-bg: #e0e0ea;
  --liquid-bg: rgba(0,0,0,0.04); --liquid-border: rgba(0,0,0,0.1);
  --aura-text: #111; --hover-bg: #f4f4f8;
  --sticky-bg: rgba(240,240,244,0.98);
  --seg-bg: #d8d8e2; --seg-active: #111; --seg-txt: #aaa; --seg-txt-active: #fff;
  --btn-ctrl-bg: #e5e5ee; --btn-ctrl-border: rgba(0,0,0,0.07);
}

/* скрыть системный скроллбар */
:global(html) { scrollbar-width: none !important; -ms-overflow-style: none !important; }
:global(html::-webkit-scrollbar) { display: none !important; }

/* LOADING */
.loading-overlay { position: fixed; inset: 0; background: #000; z-index: 2000; display: flex; justify-content: center; align-items: center; overflow: hidden; }
.diagonal-bg { position: absolute; inset: 0; background: repeating-linear-gradient(45deg,transparent,transparent 10px,rgba(255,255,255,0.3) 10px,rgba(255,255,255,0.3) 13px); background-size: 200% 200%; animation: bg-move 4s linear infinite; }
@keyframes bg-move { 0% { background-position: 0% 0%; } 100% { background-position: 100% 100%; } }
.intro-content { position: relative; z-index: 10; text-align: center; }
.intro-text { font-weight: 800; font-size: 60px; color: #fff; letter-spacing: 8px; opacity: 0; text-shadow: 0 0 15px rgba(255,255,255,0.6); animation: scale-in 1.5s cubic-bezier(0.2,0.8,0.2,1) forwards; }
@keyframes scale-in { 0% { transform: scale(0.8); opacity: 0; filter: blur(10px); } 100% { transform: scale(1); opacity: 1; filter: blur(0); } }

/* ERROR */
.error-zone { display: flex; justify-content: center; align-items: center; height: 50vh; }
.error-box-noir { text-align: center; border: 1px solid var(--border); padding: 40px 60px; border-radius: 4px; background: var(--bg); }
.err-icon { font-size: 30px; margin-bottom: 15px; color: var(--text); opacity: 0.8; }
.err-title { font-size: 14px; color: var(--text); margin-bottom: 10px; letter-spacing: 1px; }
.err-desc { font-size: 12px; color: var(--dim); margin-bottom: 25px; }
.retry-btn-noir { background: var(--text); border: none; color: var(--bg); padding: 12px 24px; font-family: 'JetBrains Mono',monospace; font-size: 11px; cursor: pointer; transition: 0.3s; text-transform: uppercase; font-weight: 700; }

/* LOGO PULSE */
.logo-pulse { position: relative; width: 32px; height: 32px; border-radius: 50%; background: var(--text); display: inline-flex; align-items: center; justify-content: center; margin-right: 10px; overflow: visible; }
.logo-dot { width: 10px; height: 10px; border-radius: 50%; background: var(--bg); position: relative; z-index: 2; }
.logo-ring { position: absolute; width: 32px; height: 32px; border-radius: 50%; box-shadow: 0 0 0 0 rgba(255,255,255,0.35); animation: ring-pulse 2.2s infinite; }
@keyframes ring-pulse { 0% { box-shadow: 0 0 0 0 rgba(255,255,255,0.35); } 70% { box-shadow: 0 0 0 14px rgba(255,255,255,0); } 100% { box-shadow: 0 0 0 0 rgba(255,255,255,0); } }

/* SCROLL WIDGET */
.scroll-widget-track { position: fixed; right: 3px; top: 15px; bottom: 15px; width: 14px; z-index: 1000; display: flex; justify-content: center; touch-action: none; }
.scroll-widget-thumb { position: absolute; width: 5px; background: var(--text); border-radius: 3px; opacity: 0.3; transition: opacity 0.2s; }
.scroll-widget-thumb:hover, .scroll-widget-track:hover .scroll-widget-thumb { opacity: 0.6; }
.scroll-widget-track::before { content: ''; position: absolute; top: 0; bottom: 0; width: 1px; background: var(--border); }

/* HEADER */
.header-manifest { margin-bottom: 20px; }
.header-inner { display: flex; align-items: center; gap: 10px; justify-content: center; }
.header-pill-btn { background: transparent; border: 1px solid var(--border); color: var(--text); border-radius: 18px; padding: 6px 12px; font-size: 11px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 5px; transition: background 0s, border-color 0s, color 0s; }
.header-pill-btn:hover { background: var(--btn-ctrl-bg); }

/* STICKY NAV */
.container { max-width: 1220px; margin: 0 auto; padding: 18px 22px; }
.table-frame { position: relative; z-index: 400; max-width: 1220px; margin: 0 auto; padding: 0 12px; }
.sticky-nav-group { position: sticky; top: 0; z-index: 700; background: var(--sticky-bg); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); box-shadow: 0 6px 30px rgba(0,0,0,0.3), 0 1px 0 var(--border); border-radius: 14px; margin-bottom: 10px; }
.controls-luxury { padding: 10px 0 0; overflow: visible; }

/* горизонтальный скролл кнопок */
.ctrl-scroll-row { overflow-x: visible; overflow-y: visible; -webkit-overflow-scrolling: touch; scrollbar-width: none; display: flex; justify-content: center; }
.ctrl-scroll-row::-webkit-scrollbar { display: none; }
.ctrl-inner-flex { display: flex; gap: 10px; padding: 0 0 10px; min-width: max-content; justify-content: center; }

/* КНОПКИ */
.control-item { position: relative; flex-shrink: 0; isolation: isolate; z-index: 710; }
.main-ctrl-btn { background: var(--btn-ctrl-bg); border: 1px solid var(--btn-ctrl-border); color: var(--text); padding: 9px 18px; border-radius: 20px; font-size: 11px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; transition: filter 0.15s; white-space: nowrap; position: relative; z-index: 710; }
.main-ctrl-btn:hover { filter: brightness(1.25); }
.main-ctrl-btn.active-mode { background: var(--text); color: var(--bg); border-color: transparent; }
.ctrl-text-bold { font-weight: 700; }
.btn-txt-fixed { max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.pill-arrow { width: 10px; height: 10px; opacity: 0.5; flex-shrink: 0; }

/* overlay ниже sticky */
.click-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 450; background: transparent; }

/* POPUP MENUS */
.bahur-popup-menu { position: absolute; top: calc(100% + 10px); background: var(--panel-bg); border: 1px solid var(--border); border-radius: 16px; padding: 15px; box-shadow: 0 20px 60px rgba(0,0,0,0.7); display: flex; flex-direction: column; gap: 10px; z-index: 800; }
.bahur-popup-menu.list-mode { left: 50%; transform: translateX(-50%); min-width: 260px; max-width: 340px; }
.bahur-popup-menu.filter-mode { left: 0; width: 220px; }
.bahur-popup-menu.center-mode { left: 0; width: 195px; padding: 12px; }

/* ТУМБЛЕРЫ */
.toggle-row { display: flex; justify-content: space-between; align-items: center; width: 100%; cursor: pointer; padding: 7px 0; border-bottom: 1px solid var(--border); gap: 8px; }
.toggle-row:last-child { border-bottom: none; }
.toggle-label { font-size: 11px; color: var(--text); font-weight: 700; display: flex; align-items: center; gap: 6px; }
.bw-toggle { width: 36px; height: 20px; border: 1px solid var(--border); border-radius: 20px; position: relative; transition: 0.3s; background: transparent; flex-shrink: 0; }
.bw-thumb { width: 14px; height: 14px; background: var(--text); border-radius: 50%; position: absolute; left: 2px; top: 2px; transition: 0.3s; }
.bw-toggle.on .bw-thumb { transform: translateX(16px); }

/* статусные метки без квадратов */
.status-chip { display: inline-flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 900; line-height: 1; padding: 0 2px; }
.chip-plus { color: #00a86b; }
.chip-star { color: #a020f0; }
.chip-minus { color: #fd4659; }

/* INPUT & BRANDS */
.popup-input { width: 100%; background: var(--seg-bg); border: 1px solid var(--border); padding: 10px; border-radius: 8px; color: var(--text); font-size: 12px; outline: none; margin-bottom: 5px; box-sizing: border-box; font-weight: 600; }
.popup-input::placeholder { opacity: 0.5; }
.search-input-box { width: 100%; }
.brands-scroll-area { max-height: 280px; overflow-y: auto; }
.custom-scroll-minimal::-webkit-scrollbar { width: 2px; }
.custom-scroll-minimal::-webkit-scrollbar-thumb { background: var(--dim); }
.brands-list-vertical { display: flex; flex-direction: column; gap: 4px; }
.brand-row-btn { display: flex; justify-content: space-between; align-items: center; background: transparent; color: var(--text); border: none; padding: 10px; border-radius: 6px; cursor: pointer; font-size: 12px; text-align: left; transition: 0.15s; opacity: 0.8; font-weight: 600; }
.all-brand-btn { opacity: 1; font-weight: 800; margin-bottom: 5px; border-bottom: 1px solid var(--border); padding-bottom: 10px; border-radius: 0; }
.brand-row-btn:hover { background: var(--seg-bg); opacity: 1; }
.brand-font-fix { font-weight: 700; font-size: 12px; opacity: 0.9; }
.brand-left-group { display: flex; align-items: center; gap: 8px; overflow: hidden; }
.brand-txt-truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px; }
.circle-check-icon.left { margin-right: 5px; width: 16px; height: 16px; }
.check-status.right { width: 14px; height: 14px; }

/* СЕГМЕНТЫ */
.popup-section { margin-bottom: 5px; }
.popup-label { display: block; font-size: 9px; font-weight: 800; color: var(--dim); margin-bottom: 6px; letter-spacing: 1px; text-transform: uppercase; }
.segmented-control { display: flex; background: #070709; padding: 3px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.04); }
.bahur-terminal:not(.noir) .segmented-control { background: #cecede; border-color: rgba(0,0,0,0.06); }
.segment-btn { flex: 1; background: transparent; border: none; color: #555; padding: 6px 0; font-size: 10px; font-weight: 700; border-radius: 6px; cursor: pointer; transition: 0.12s; }
.segment-btn.active { background: #fff; color: #000; box-shadow: 0 2px 6px rgba(0,0,0,0.5); font-weight: 800; }
.bahur-terminal:not(.noir) .segment-btn { color: #aaa; }
.bahur-terminal:not(.noir) .segment-btn.active { background: #111; color: #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.2); }
.arrows-horn { font-size: 10px; display: inline-flex; gap: 2px; }

.pop-enter-active, .pop-leave-active { transition: all 0.18s cubic-bezier(0.16,1,0.3,1); }
.pop-enter-from, .pop-leave-to { opacity: 0; transform: translateY(-8px) scale(0.96); }

/* DASHBOARD */
.dash-collapsible-wrapper { display: grid; grid-template-rows: 0fr; transition: grid-template-rows 0.3s cubic-bezier(0.4,0,0.2,1); }
.dash-collapsible-wrapper.open { grid-template-rows: 1fr; margin-bottom: 20px; }
.dash-inner-content { overflow: hidden; }
.dash-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 10px; }
.stat-card { border: 1px solid var(--border); padding: 18px; background: var(--card-bg); border-left: 3px solid var(--text); border-radius: 12px; }
.d-label { display: block; font-size: 9px; font-weight: 800; color: var(--dim); margin-bottom: 12px; letter-spacing: 1.5px; text-transform: uppercase; }
.stat-card .v { font-size: 24px; font-weight: 800; }
.q-row-stacked { margin-bottom: 10px; }
.q-meta { display: flex; justify-content: space-between; font-size: 10px; font-weight: 700; margin-bottom: 5px; }
.op-5 { opacity: 0.5; }
.q-track-neon { height: 2px; background: var(--border); width: 100%; overflow: hidden; border-radius: 1px; }
.q-fill-neon { height: 100%; background: var(--text); }
.white-part { background: #fff; }
.split-top-row { display: flex; justify-content: space-between; gap: 20px; }
.st-item, .st-price-box { flex: 1; }
.st-sep { width: 1px; background: var(--border); margin: 0 10px; opacity: 0.5; }
.avg-price-flex { display: flex; flex-direction: column; gap: 4px; }
.ap-item { font-family: 'JetBrains Mono',monospace; font-size: 12px; color: var(--dim); font-weight: 600; }
.ap-item .val { color: var(--text); font-weight: 800; font-size: 13px; margin-left: 5px; }
.stock-stack-info { display: flex; flex-direction: column; margin-top: 10px; gap: 2px; }
.ss-row { font-size: 11px; color: var(--dim); font-weight: 700; }
.ss-row span { color: var(--text); margin-left: 4px; }
.stock-layout { display: flex; justify-content: space-between; align-items: center; }
.stock-left { flex-shrink: 0; margin-right: 15px; }
.stock-big-num { font-size: 32px; font-weight: 800; line-height: 1; }
.stock-right { flex-grow: 1; display: flex; flex-direction: column; justify-content: center; }
.q-track-neon-thick { height: 6px; background: var(--border); width: 100%; border-radius: 3px; overflow: hidden; margin-bottom: 6px; }
.q-fill-neon-thick { height: 100%; background: #fff; }
.stock-missing-text { font-size: 10px; color: var(--dim); text-align: right; font-weight: 600; }

.top-header-center { display: flex; justify-content: center; margin-bottom: 10px; }
.top-switch-btn-subtle { background: transparent; border: 1px solid var(--border); color: var(--text); padding: 5px 12px; border-radius: 20px; font-size: 10px; font-weight: 700; cursor: pointer; }
.btn-subtle-label { color: var(--dim); }

/* РЕЙТИНГ */
.top-list-scroll-container { max-height: 120px; overflow-y: auto; overflow-x: hidden; display: flex; flex-direction: column; gap: 3px; padding-right: 4px; scrollbar-width: thin; scrollbar-color: rgba(128,128,128,0.3) transparent; }
.top-list-scroll-container::-webkit-scrollbar { width: 2px; }
.top-list-scroll-container::-webkit-scrollbar-track { background: transparent; }
.top-list-scroll-container::-webkit-scrollbar-thumb { background: rgba(128,128,128,0.3); border-radius: 2px; }

.top-row-compact { display: grid; grid-template-columns: minmax(0, 2fr) minmax(0, 1fr) auto; align-items: center; gap: 6px; font-size: 11px; padding: 3px 0; border-bottom: 1px solid var(--border); min-width: 0; }
.top-row-compact:last-child { border-bottom: none; }

.tr-left-main { display: flex; align-items: center; min-width: 0; overflow: hidden; }
.top-num { color: var(--dim); margin-right: 4px; font-weight: 700; flex-shrink: 0; font-size: 10px; }
.top-name { overflow: hidden; white-space: nowrap; text-overflow: ellipsis; font-weight: 700; min-width: 0; }

.tr-mid-graph { display: flex; align-items: center; min-width: 0; }
.mini-bar-track { width: 100%; height: 2px; background: var(--border); border-radius: 1px; overflow: hidden; }
.mini-bar-fill { height: 100%; background: var(--text); }

.tr-right-meta { display: flex; align-items: center; gap: 3px; flex-shrink: 0; }
.badge-mini { border: 1px solid var(--border); padding: 2px 6px; font-size: 10px; color: var(--text); border-radius: 6px; font-weight: 800; white-space: nowrap; min-width: 42px; height: 22px; display: inline-flex; align-items: center; justify-content: center; }
.top-val { font-weight: 800; min-width: 28px; text-align: right; font-size: 10px; }

/* ШАПКА ТАБЛИЦЫ */
.grid-layout-def.head { display: grid; grid-template-columns: var(--col-id) 1fr var(--col-meta) var(--col-meta) var(--col-meta) calc(var(--p-cols) * var(--col-price)); align-items: stretch; box-sizing: border-box; width: 100%; border: none; background: transparent; padding: 4px 6px; }

.search-cell-dark { padding: 4px !important; }
.header-search-container { display: flex; align-items: center; width: 100%; height: 52px; background: var(--search-pill-bg); border-radius: 12px; position: relative; overflow: hidden; }
.header-search-container .search-icon { position: absolute; left: 12px; width: 14px; height: 14px; color: var(--dim); pointer-events: none; }
.header-search-input { width: 100%; height: 100%; background: transparent; border: none; padding: 10px 30px 10px 34px; outline: none; color: var(--text); font-size: 11px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase; font-family: 'Kollektif', 'Nunito', sans-serif; }
.header-search-input::placeholder { color: var(--dim); font-weight: 800; }
.header-search-container .clear-search { position: absolute; right: 10px; background: transparent; border: none; color: var(--dim); cursor: pointer; font-size: 11px; font-weight: bold; }

/* Заголовки */
.head-meta-cell { padding: 4px !important; display: flex !important; align-items: stretch !important; }
.head-meta-pill { display: flex; align-items: center; justify-content: center; width: 100%; flex: 1; height: 44px; min-height: 44px; background: var(--inner-pill-meta); border-radius: 10px; padding: 0 8px; font-size: 10px; font-weight: 800; color: var(--dim); letter-spacing: 1px; text-transform: uppercase; white-space: nowrap; font-family: 'Kollektif', 'Nunito', sans-serif; box-sizing: border-box; }
.head-price-pill { display: flex; align-items: center; justify-content: center; width: 100%; flex: 1; height: 44px; min-height: 44px; background: var(--inner-pill-dark); border-radius: 10px; padding: 0 4px; font-size: 11px; font-weight: 800; color: var(--dim); letter-spacing: 1px; text-transform: uppercase; white-space: nowrap; font-family: 'JetBrains Mono', monospace; box-sizing: border-box; }

/* ТАБЛИЦА */
.grid-table { display: flex; flex-direction: column; gap: 8px; width: 100%; max-width: 1220px; margin: 0 auto; border: none; padding-top: 8px; }

.grid-layout-def:not(.head) { display: grid; grid-template-columns: var(--col-id) 1fr var(--col-meta) var(--col-meta) var(--col-meta) calc(var(--p-cols) * var(--col-price)); align-items: stretch; box-sizing: border-box; width: 100%; background: var(--card-bg); border: 1px solid var(--card-border); border-radius: 14px; position: relative; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.15); transition: transform 0.2s, box-shadow 0.2s, background 0.2s; padding: 6px; }

.grid-layout-def.clickable-row:hover,
.grid-layout-def.clickable-row.simulated-hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(0,0,0,0.2); background: var(--hover-bg); }

.cell { height: auto; display: flex; align-items: center; padding: 4px; border-right: none !important; box-sizing: border-box; overflow: hidden; }
.head-txt { font-size: 9px; font-weight: 800; color: var(--dim); text-transform: uppercase; letter-spacing: 1.5px; padding: 12px; }
.center { justify-content: center; text-align: center; }
.row-visual-layer { display: contents; }
.clickable-row { cursor: pointer; }
.out { opacity: 0.4; filter: grayscale(50%); }

/* ПЛАШКИ */
.inner-pill-main { background: var(--inner-pill-name); border-radius: 14px; padding: 10px 14px; width: 100%; display: flex; flex-direction: column; justify-content: center; min-height: 56px; box-sizing: border-box; }

.inner-pill-badge { background: var(--inner-pill-meta); border-radius: 10px; padding: 0 8px; font-weight: 800; font-size: 10px; color: var(--text); width: 100%; text-align: center; height: 44px; min-height: 44px; display: flex; align-items: center; justify-content: center; box-sizing: border-box; }
.inner-pill-badge.meta-badge { background: var(--inner-pill-meta); }

.inner-pill-badge-mobile { background: var(--inner-pill-meta); border-radius: 8px; padding: 4px 6px; font-weight: 800; font-size: 9px; color: var(--text); border: none; display: flex; align-items: center; justify-content: center; }

/* Цены */
.inner-pill-price { background: var(--inner-pill-dark); border-radius: 10px; padding: 0 4px; font-weight: 800; font-size: 12px; display: flex; align-items: center; justify-content: center; width: 100%; box-sizing: border-box; height: 44px; min-height: 44px; }

/* СТАТУСЫ */
.status-symbol { font-size: 18px; font-weight: 900; margin-top: 2px; line-height: 1; }
.sym-plus, .sym-star, .sym-minus { display: inline-block; }
.jade-txt { color: #00a86b; }
.purple-txt { color: #a020f0; }
.watermelon-txt { color: #fd4659; }

.id-zone-square { flex-direction: column; gap: 2px; justify-content: center; }
.id-sq-top { font-size: 15px; font-weight: 900; color: var(--dim); }
.brand-code { font-size: 10px; font-weight: 400; opacity: 0.45; display: block; text-transform: uppercase; letter-spacing: 1px; }
.scent-title { font-weight: 700; font-size: 16px; line-height: 1.2; letter-spacing: 0.3px; }
.mobile-only-meta { display: none; margin-top: 7px; gap: 4px; align-items: center; }

.price-container { width: calc(var(--p-cols) * var(--col-price)); display: flex; align-items: stretch; }
.price-section { display: grid; gap: 6px; width: 100%; padding: 0 4px; }
.head-p { padding: 4px; display: grid; align-items: stretch; }
.head-p .p-col { display: flex; align-items: stretch; justify-content: center; }

/* LIQUID EYE */
.liquid-filter { display: none; }
.row-aura-overlay { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; opacity: 0; transition: opacity 0.4s cubic-bezier(0.25,0.8,0.25,1); z-index: 10; pointer-events: none; backdrop-filter: blur(8px) saturate(1.3); -webkit-backdrop-filter: blur(8px) saturate(1.3); background: var(--liquid-bg); border-radius: inherit; border: 1px solid transparent; }
.clickable-row:hover .row-aura-overlay,
.clickable-row.simulated-hover .row-aura-overlay { opacity: 1; border-color: var(--liquid-border); animation: liquid-pulse 2.5s ease-in-out infinite; }
@keyframes liquid-pulse { 0%, 100% { backdrop-filter: blur(8px) saturate(1.3); background: var(--liquid-bg); } 50% { backdrop-filter: blur(12px) saturate(1.6); background: var(--liquid-bg); filter: brightness(1.05); } }
.aura-text { font-size: 11px; font-weight: 700; letter-spacing: 4px; color: var(--aura-text); transform: translateY(12px) scale(0.97); opacity: 0; transition: 0.45s cubic-bezier(0.25,0.8,0.25,1); text-transform: uppercase; text-shadow: 0 0 20px currentColor; }
.clickable-row:hover .aura-text,
.clickable-row.simulated-hover .aura-text { opacity: 1; transform: translateY(0) scale(1); }

/* МОБИЛЬ */
@media (max-width: 900px) {
  .container { padding: 14px; }
  .dash-grid { grid-template-columns: 1fr 1fr; }
  .span-full { grid-column: span 2; }
  .grid-table { min-width: 100%; max-width: 100%; }
  .cell { border-right: none; }
  .desk-only { display: none !important; }
  .grid-layout-def.head .desk-only { display: none !important; }
  .mobile-only-meta { display: flex; }

  .scroll-widget-track { display: none !important; }

  .sticky-nav-group { border-radius: 0 0 18px 18px; margin-left: -10px; margin-right: -10px; padding-left: 10px; padding-right: 10px; }

  .ctrl-scroll-row { overflow-x: visible; }
  .ctrl-inner-flex { display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px; padding: 0 0 10px; min-width: 0; width: 100%; }
  .control-item { flex-shrink: unset; width: 100%; }
  .main-ctrl-btn { width: 100%; padding: 10px 8px; font-size: 11px; justify-content: center; }
  .pill-arrow { display: none; }

  .grid-layout-def.head { grid-template-columns: 34px 1fr calc(var(--p-cols) * 38px); padding: 2px 4px; }
  .grid-layout-def:not(.head) { grid-template-columns: 34px 1fr calc(var(--p-cols) * 38px); padding: 3px; border-radius: 12px; }

  .id-zone-square { padding: 0 !important; align-items: center; justify-content: center; }
  .id-sq-top { font-size: 11px; margin-bottom: 1px; }
  .status-symbol { font-size: 12px; margin-top: 0; }

  .inner-pill-main { padding: 5px 4px 5px 8px; border-radius: 9px; min-height: 0; }
  .scent-title { font-size: 12px; line-height: 1.15; }
  .brand-code { font-size: 8px; }
  .mobile-only-meta { margin-top: 4px; gap: 3px; }
  .inner-pill-badge-mobile { padding: 3px 5px; font-size: 8px; border-radius: 5px; }

  .price-container { width: calc(var(--p-cols) * 38px); display: flex; align-items: stretch; }
  .price-section { gap: 2px; padding: 0; align-items: stretch; }
  .inner-pill-price { padding: 0 2px; font-size: 11px; border-radius: 8px; height: auto; min-height: 0; flex: 1; }

  .search-cell-dark { padding: 3px !important; }
  .header-search-container { border-radius: 8px; min-height: 36px; height: 40px; }
  .header-search-container .search-icon { left: 8px; width: 11px; height: 11px; }
  .header-search-input { padding: 7px 20px 7px 24px; font-size: 9px; }
  .header-search-container .clear-search { right: 6px; }
  .head-p { padding: 2px; }

  .aura-text { font-size: 9px; letter-spacing: 2px; }

  .bahur-popup-menu { position: fixed !important; top: auto !important; bottom: 20px !important; left: 15px !important; right: 15px !important; width: auto !important; max-width: none !important; transform: none !important; z-index: 2000 !important; }
}
</style>
```
