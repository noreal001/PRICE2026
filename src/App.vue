<template>
  <div :class="['bahur-terminal', { 'noir': isDark }]" :style="{ '--p-cols': activePriceCount }">
    <div class="container">
      
      <header class="header-manifest">
        <div class="logo-strip-box">
          <div class="strip top"></div>
          <h1 class="logo-text">BAHUR</h1>
          <div class="strip bottom"></div>
          <div class="logo-url">www.bahur.store</div>
          
          <button @click="isDark = !isDark" class="header-icon-btn theme-pos">
            <svg v-if="isDark" class="h-icon" viewBox="0 0 24 24"><path fill="currentColor" d="M12,7A5,5 0 0,1 17,12A5,5 0 0,1 12,17A5,5 0 0,1 7,12A5,5 0 0,1 12,7M12,9A3,3 0 0,0 9,12A3,3 0 0,0 12,15A3,3 0 0,0 15,12A3,3 0 0,0 12,9M12,2L14.39,5.42C13.65,5.15 12.84,5 12,5C11.16,5 10.35,5.15 9.61,5.42L12,2M3.34,7L7.5,7.46C7.18,8.14 7,8.89 7,9.67V14.33C7,15.11 7.18,15.86 7.5,16.54L3.34,17L5.36,12L3.34,7M12,22L9.61,18.58C10.35,18.85 11.16,19 12,19C12.84,19 13.65,18.85 14.39,18.58L12,22M20.66,7L18.64,12L20.66,17L16.5,16.54C16.82,15.86 17,15.11 17,14.33V9.67C17,8.89 16.82,8.14 16.5,7.46L20.66,7Z" /></svg>
            <svg v-else class="h-icon" viewBox="0 0 24 24"><path fill="currentColor" d="M17.75,4.09L15.22,6.03L16.13,9.09L13.5,7.28L10.87,9.09L11.78,6.03L9.25,4.09L12.44,4L13.5,1L14.56,4L17.75,4.09M21.25,11L19.61,12.25L20.2,14.23L18.5,13.06L16.8,14.23L17.39,12.25L15.75,11L17.81,10.95L18.5,9L19.19,10.95L21.25,11M18.97,15.95C19.8,15.87 20.69,17.05 20.16,17.8C19.84,18.25 19.5,18.67 19.08,19.07C15.17,23 8.84,23 4.94,19.07C1.03,15.17 1.03,8.83 4.94,4.93C5.34,4.53 5.76,4.17 6.21,3.85C6.96,3.32 8.14,4.21 8.06,5.04C6.93,8.39 8.5,12.5 12.31,14.31C14.12,15.17 16.5,15.2 18.97,15.95M17.33,17.97C14.5,17.81 11.7,16.64 9.53,14.5C7.3,12.23 6.13,9.3 5.96,6.38C3.2,10.12 3.66,15.29 7.15,18.78C10.63,22.27 15.8,22.73 19.54,19.97C18.86,19.43 18.12,18.77 17.33,17.97Z" /></svg>
          </button>
        </div>
      </header>

      <div v-if="loading" class="loading-overlay">
         <div class="action-loader">
            <span class="thin-hero-text">BAHUR</span>
            <div class="scan-line"></div>
         </div>
      </div>

      <div v-if="errorMsg" class="error-zone">
        <div class="error-box-noir">
          <div class="err-icon">✕</div>
          <h3 class="err-title mono">ОШИБКА ПОДКЛЮЧЕНИЯ</h3>
          <p class="err-desc">{{ errorMsg }}</p>
          <div class="err-action">
             <button @click="loadData" class="retry-btn-noir">
               <span class="btn-text">ПОВТОРИТЬ</span>
             </button>
          </div>
        </div>
      </div>

      <div v-else-if="!loading">
        
        <div class="dash-control-bar">
           <button @click="showDash = !showDash" class="header-icon-btn stats-pos" title="Статистика">
             <svg :class="['h-icon', { 'closed-arrow': !showDash }]" viewBox="0 0 24 24"><path fill="currentColor" d="M13,9H18.5L13,3.5V9M6,2H14L20,8V20A2,2 0 0,1 18,22H6C4.89,22 4,21.1 4,20V4C4,2.89 4.89,2 6,2M7,20H9V14H7V20M11,20H13V12H11V20M15,20H17V16H15V20Z" /></svg>
           </button>
        </div>

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
                   <div class="stock-head">
                      <label class="d-label">СКЛАД</label>
                      <span class="v-small mono">{{ stats.availability }}%</span>
                   </div>
                   <div class="q-track-neon mb-1"><div class="q-fill-neon white-part" :style="{ width: stats.availability + '%' }"></div></div>
                   <div class="mini-stat-row center-text">В наличии: {{ stats.countAvail }} | Нет: {{ stats.countOut }}</div>
                </div>

                <div class="stat-card">
                  <label class="d-label">ФАБРИКИ %</label>
                  <div class="q-list">
                    <div v-for="f in ['Luzi', 'Eps', 'Seluz']" :key="f" class="q-row-stacked">
                      <div class="q-meta"><span class="mono">{{ f }}</span><span class="mono op-5">{{ stats.factoryPerc[f.toUpperCase()] }}%</span></div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.factoryPerc[f.toUpperCase()] + '%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card">
                  <label class="d-label">КАЧЕСТВО %</label>
                  <div class="q-list">
                    <div v-for="q in ['Top', 'Q1', 'Q2']" :key="q" class="q-row-stacked">
                      <div class="q-meta"><span class="mono">{{ q }}</span><span class="mono op-5">{{ stats.qualityPerc[q.toUpperCase()] }}%</span></div>
                      <div class="q-track-neon"><div class="q-fill-neon" :style="{ width: stats.qualityPerc[q.toUpperCase()] + '%' }"></div></div>
                    </div>
                  </div>
                </div>

                <div class="stat-card relative-zone span-full">
                  <div class="top-row-flex">
                    <label class="d-label">ТОП: {{ statsMode === '6m' ? '6 МЕС' : 'ВСЕ' }}</label>
                    <button @click="toggleStatsMode" class="mini-arrow-btn mode-switch" title="Переключить">⇄</button>
                  </div>
                  <div class="top-list-scroll-container custom-scroll-minimal">
                     <div v-for="(item, idx) in stats.topListFull" :key="idx" class="top-row-compact">
                        <div class="tr-left-main">
                           <span class="top-num mono">{{ idx + 1 }}.</span>
                           <span class="top-name rus-font" :title="item.name">{{ item.name }}</span>
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
          <div class="sticky-nav-group">
            
            <section class="controls-luxury relative-zone">
              <div class="ctrl-wrapper-desktop">
                
                <div class="left-group">
                  <div class="control-item relative-zone">
                     <button @click="toggleBrandMenu" :class="['main-ctrl-btn', { 'active': showBrandMenu || selectedBrands.length > 0 }]">
                        <span class="btn-txt-fixed rus-font ctrl-text-bold">{{ brandLabel }}</span>
                        <svg class="pill-arrow" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10L7.41 8.59Z"/></svg>
                     </button>
                     <transition name="pop">
                        <div v-if="showBrandMenu" class="bahur-popup-menu list-mode">
                           <div class="search-input-box">
                              <input v-model="tempBrandInput" type="text" inputmode="search" placeholder="Поиск бренда..." class="popup-input rus-font" />
                           </div>
                           <div class="brands-scroll-area custom-scroll-minimal">
                              <div class="brands-list-vertical">
                                <button @click="clearBrands" class="brand-row-btn rus-font all-brand-btn">
                                  <div class="brand-left-group">
                                     <svg class="circle-check-icon left" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z" /></svg>
                                     <span>Все</span>
                                  </div>
                                </button>
                                <button v-for="b in filteredBrandsDropdown" :key="b" @click="toggleBrandSelection(b)" class="brand-row-btn eng-font brand-font-fix">
                                  <div class="brand-left-group"><span class="brand-txt-truncate">{{ b }}</span></div>
                                  <svg v-if="selectedBrands.includes(b)" class="check-status right" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z" /></svg>
                                </button>
                                <div v-if="filteredBrandsDropdown.length === 0" class="no-results rus-font">Нет совпадений</div>
                              </div>
                           </div>
                        </div>
                     </transition>
                  </div>

                  <div class="control-item relative-zone">
                     <button @click="toggleAromaMenu" :class="['main-ctrl-btn', { 'active': showAromaMenu || selectedAromas.length > 0 }]">
                        <span class="btn-txt-fixed rus-font ctrl-text-bold">{{ aromaLabel }}</span>
                        <svg class="pill-arrow" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10L7.41 8.59Z"/></svg>
                     </button>
                     <transition name="pop">
                        <div v-if="showAromaMenu" class="bahur-popup-menu list-mode">
                           <div class="search-input-box">
                              <input v-model="tempAromaInput" type="text" inputmode="search" placeholder="Поиск аромата..." class="popup-input rus-font" />
                           </div>
                           <div class="brands-scroll-area custom-scroll-minimal">
                              <div class="brands-list-vertical">
                                <button @click="clearAromas" class="brand-row-btn rus-font all-brand-btn">
                                  <div class="brand-left-group">
                                     <svg class="circle-check-icon left" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.5 2 2 6.5 2 12S6.5 22 12 22 22 17.5 22 12 17.5 2 12 2M10 17L5 12L6.41 10.59L10 14.17L17.59 6.58L19 8L10 17Z" /></svg>
                                     <span>Все</span>
                                  </div>
                                </button>
                                <button v-for="(item, index) in aromaSuggestions" :key="index" @click="toggleAromaSelection(item.name)" class="brand-row-btn">
                                  <div class="brand-left-group">
                                    <span class="aroma-sug-brand eng-font">{{ item.brand }}</span>
                                    <span class="aroma-sug-name rus-font">{{ item.name }}</span>
                                  </div>
                                  <svg v-if="selectedAromas.includes(item.name)" class="check-status right" viewBox="0 0 24 24"><path fill="currentColor" d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z" /></svg>
                                </button>
                                <div v-if="aromaSuggestions.length === 0 && tempAromaInput" class="no-results rus-font">Нет совпадений</div>
                              </div>
                           </div>
                        </div>
                     </transition>
                  </div>

                  <div class="control-item">
                    <button @click="toggleNew" :class="['main-ctrl-btn', { 'active': isNewOnly }]"><span class="rus-font ctrl-text-bold">Новинки</span></button>
                  </div>
                </div>

                <div class="right-group">
                  <div class="control-item relative-zone">
                    <button @click="toggleFilterMenu" :class="['main-ctrl-btn', { 'active': showFilters }]">
                      <span class="rus-font ctrl-text-bold">{{ showFilters ? 'Закрыть' : 'Фильтр' }}</span>
                      <svg class="pill-arrow" viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17L16.59 8.59L18 10L12 16L6 10L7.41 8.59Z"/></svg>
                    </button>
                     <transition name="pop">
                      <div v-if="showFilters" class="bahur-popup-menu filter-mode">
                        <div class="popup-section">
                          <span class="popup-label rus-font">Пол</span>
                          <div class="segmented-control">
                            <button v-for="g in genderOptions" :key="g.val" @click="activeGender = g.val" :class="['segment-btn', { active: activeGender === g.val }]"><span class="rus-font">{{ g.label }}</span></button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label rus-font">Фабрика</span>
                          <div class="segmented-control">
                            <button v-for="f in factoryOptions" :key="f.val" @click="activeFactory = f.val" :class="['segment-btn', { active: activeFactory === f.val }]"><span class="eng-font">{{ f.label }}</span></button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label rus-font">Качество</span>
                          <div class="segmented-control">
                            <button v-for="q in qualityOptions" :key="q.val" @click="activeQuality = q.val" :class="['segment-btn', { active: activeQuality === q.val }]"><span class="eng-font">{{ q.label }}</span></button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label rus-font">Цена</span>
                          <div class="segmented-control">
                            <button v-for="s in sortOptions" :key="s.val" @click="sortBy = s.val" :class="['segment-btn', { active: sortBy === s.val }]">
                               <span v-if="s.val === 'id'" class="rus-font">ID</span>
                               <span v-else class="arrows-horn"><b>{{ s.label }}</b>{{ s.val === 'asc' ? '▲' : '▼' }}</span>
                            </button>
                          </div>
                        </div>
                        <div class="popup-section">
                          <span class="popup-label rus-font">Столбцы</span>
                          <div class="segmented-control">
                            <button v-for="(val, key) in priceLabels" :key="key" @click="togglePrice(key)" :class="['segment-btn', { active: showPrices[key] }]"><span class="rus-font">{{ val }}</span></button>
                          </div>
                        </div>
                      </div>
                    </transition>
                  </div>
                </div>

              </div>
              <div v-if="showFilters || showBrandMenu || showAromaMenu" class="click-overlay" @click="closeAllMenus"></div>
            </section>

            <div class="grid-layout-def head no-click">
              <div class="cell id head-txt center">№</div>
              <div class="cell name name-header"><span class="head-txt">Ароматы</span></div>
              <div class="cell desk-only head-txt center">Пол</div>
              <div class="cell desk-only head-txt center">Фабрика</div>
              <div class="cell desk-only head-txt center">Качество</div>
              <div class="price-section head-p" :style="priceSubGridStyle">
                <div v-if="showPrices.p50" class="p-col line center">50г</div>
                <div v-if="showPrices.p500" class="p-col line center">500г</div>
                <div v-if="showPrices.p1000" class="p-col last center">1кг</div>
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
                  <div v-if="p.isNew" class="badge-new-box desk-only-new">NEW</div>
                  <div :class="['lamp-sq', p.isOut ? 'red' : (p.isNew ? 'green' : 'standard')]"></div>
                </div>
                <div class="cell name border-right-mobile">
                  <div class="scent-info">
                    <span class="brand-code eng-font">{{ p.brand }}</span>
                    <span class="scent-title rus-font">{{ p.name }}</span>
                    <div class="mobile-only-meta">
                      <span class="m-square-matte">{{ getSex(p.gender) }}</span> 
                      <span class="m-square-matte">{{ p.factory }}</span> 
                      <span class="m-square-matte">{{ p.quality }}</span>
                      <span v-if="p.isNew" class="m-square-matte new-mobile">NEW</span>
                    </div>
                  </div>
                </div>
                <div class="cell desk-only center"><div class="badge-square-matte">{{ getSex(p.gender) }}</div></div>
                <div class="cell desk-only center"><div class="badge-square-matte">{{ p.factory }}</div></div>
                <div class="cell desk-only center"><div class="badge-square-matte">{{ p.quality }}</div></div>
                <div class="price-container">
                  <div class="price-section mono center" :style="priceSubGridStyle">
                    <div v-if="showPrices.p50" class="p-col line">{{ p.p50 }}₽</div>
                    <div v-if="showPrices.p500" class="p-col line">{{ p.p500 }}₽</div>
                    <div v-if="showPrices.p1000" class="p-col bold last">{{ p.p1000 }}₽</div>
                  </div>
                </div>
              </div>
              <div class="row-aura-overlay"><span class="aura-text">ПЕРЕЙТИ К АРОМАТУ</span></div>
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
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'

const isDark = ref(true); 
const loading = ref(true); 
const errorMsg = ref(null);
const products = ref([]); 
const showDash = ref(true);

const statsMode = ref('6m'); 
const toggleStatsMode = () => statsMode.value = statsMode.value === '6m' ? 'all' : '6m';

const selectedBrands = ref([]); 
const tempBrandInput = ref('');
const showBrandMenu = ref(false);

const selectedAromas = ref([]);
const tempAromaInput = ref('');
const showAromaMenu = ref(false);

const showFilters = ref(false);
const isNewOnly = ref(false);
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

const toggleNew = () => isNewOnly.value = !isNewOnly.value;
const togglePrice = (key) => {
  const activeKeys = Object.values(showPrices.value).filter(Boolean);
  if (showPrices.value[key] && activeKeys.length === 1) return;
  showPrices.value[key] = !showPrices.value[key];
}
const toggleFilterMenu = () => { if (showFilters.value) { closeAllMenus(); return; } closeAllMenus(); showFilters.value = true; }
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
const toggleAromaMenu = () => { 
  if (showAromaMenu.value) { closeAllMenus(); return; } 
  closeAllMenus(); showAromaMenu.value = true; tempAromaInput.value = ''; 
}
const toggleAromaSelection = (a) => {
  const idx = selectedAromas.value.indexOf(a);
  if (idx === -1) selectedAromas.value.push(a); else selectedAromas.value.splice(idx, 1);
  closeAllMenus();
}
const clearAromas = () => { selectedAromas.value = []; closeAllMenus(); }
const closeAllMenus = () => { showFilters.value = false; showBrandMenu.value = false; showAromaMenu.value = false; }

const brandLabel = computed(() => { 
  const len = selectedBrands.value.length; 
  if (len === 0) return 'Бренды'; 
  return `${len} Бренд${len > 1 ? 'а' : ''}`; 
});
const aromaLabel = computed(() => { 
  const len = selectedAromas.value.length; 
  if (len === 0) return 'Ароматы'; 
  return `${len} Аромат${len > 1 ? 'а' : ''}`; 
});

const priceSubGridStyle = computed(() => ({ gridTemplateColumns: `repeat(${activePriceCount.value}, 1fr)` }));

// SCROLL WIDGET LOGIC
const scrollTrack = ref(null);
const thumbTop = ref(0);
const thumbHeight = ref(10); // Percent

const updateThumb = () => {
  const winH = window.innerHeight;
  const docH = document.documentElement.scrollHeight;
  const scrollY = window.scrollY;
  const ratio = winH / docH;
  thumbHeight.value = Math.max(ratio * 100, 5); 
  const maxScroll = docH - winH;
  if (maxScroll <= 0) { thumbTop.value = 0; return; }
  const percent = scrollY / maxScroll;
  const trackAvailable = 100 - thumbHeight.value;
  thumbTop.value = percent * trackAvailable;
}

const handleDrag = (clientY) => {
  const track = scrollTrack.value;
  if (!track) return;
  const rect = track.getBoundingClientRect();
  const relY = clientY - rect.top;
  const trackH = rect.height;
  
  const percent = Math.min(Math.max(relY / trackH, 0), 1);
  
  const docH = document.documentElement.scrollHeight;
  const winH = window.innerHeight;
  const targetScroll = percent * (docH - winH);
  
  window.scrollTo({ top: targetScroll, behavior: 'auto' });
}

let isDragging = false;

const startDrag = (e) => {
  isDragging = true;
  const clientY = e.touches ? e.touches[0].clientY : e.clientY;
  handleDrag(clientY);
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

const trackClick = (e) => {
  handleDrag(e.clientY);
}

const parseCSV = (data) => {
  try {
    const rows = data.split(/\r?\n/).filter(line => line.trim());
    return rows.map((row, idx) => {
      const col = row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).map(c => c.replace(/^"|"$/g, '').trim());
      if (!col[0] || isNaN(parseInt(col[0])) || !col[2]) return null;
      let g = col[4] ? col[4].toLowerCase().trim() : '';
      let fG = (g === 'm' || g === 'м' || g.includes('муж')) ? 'm' : (g === 'w' || g === 'ж' || g.includes('жен')) ? 'w' : (g === 'y' || g === 'у' || g.includes('уни')) ? 'y' : '';
      const statusCol = col[10] ? col[10].trim() : '';
      const rawNote = (col[11] || '').toUpperCase();
      const brand = col[2] || '';
      const name = col[3] || '';
      const hasPlus = statusCol.includes('+'); 
      const hasMinus = statusCol.includes('-'); 
      const isNew = hasPlus || statusCol.toUpperCase().includes('NEW') || rawNote.includes('NEW') || brand.toUpperCase().includes('NEW') || name.toUpperCase().includes('NEW');
      const isOut = hasMinus;
      const sales6m = parseFloat(col[11]) || 0;
      const salesAll = parseFloat(col[12]) || 0;
      return { id: col[0], link: col[1] || '', brand: brand, name: name, gender: fG, factory: col[5] || '', quality: col[6] || '', p50: parseInt(col[7]) || 0, p500: parseInt(col[8]) || 0, p1000: parseInt(col[9]) || 0, status: statusCol, isOut: isOut, isNew: isNew, sales6m: sales6m, salesAll: salesAll }
    }).filter(p => p !== null);
  } catch(err) { console.error("CSV Parse Error", err); return []; }
}

const loadData = async () => {
  loading.value = true;
  errorMsg.value = null;
  try {
    const res = await fetch('https://docs.google.com/spreadsheets/d/e/2PACX-1vTtT4zLEY49maKt0VxanZWA2ORKO1h39Mc5wB-XcZclDTmWfroFxQNAPxomg3x0-w/pub?gid=1234145733&single=true&output=csv');
    if (!res.ok) throw new Error('Ошибка сети');
    const txt = await res.text();
    products.value = parseCSV(txt);
    if (products.value.length === 0) throw new Error('Данные пусты или ошибка формата');
    startAutoHighlight();
    setTimeout(() => loading.value = false, 1500);
  } catch (e) { console.error(e); errorMsg.value = "Не удалось подключиться к базе данных. Проверьте соединение."; loading.value = false; }
}

const startAutoHighlight = () => {
  if (highlightInterval) clearInterval(highlightInterval);
  highlightInterval = setInterval(() => {
    if (sortedProducts.value.length > 0) {
      const randomIdx = Math.floor(Math.random() * sortedProducts.value.length);
      const product = sortedProducts.value[randomIdx];
      if (product) { autoHighlightId.value = product.id; setTimeout(() => { autoHighlightId.value = null; }, 2000); }
    }
  }, 5000);
}

const uniqueBrands = computed(() => { const brands = new Set(); products.value.forEach(p => { if(p.brand) brands.add(p.brand); }); return Array.from(brands).sort(); });
const filteredBrandsDropdown = computed(() => { const s = tempBrandInput.value.toLowerCase(); if (!s) return uniqueBrands.value; return uniqueBrands.value.filter(b => b.toLowerCase().includes(s)); });
const aromaSuggestions = computed(() => { const s = tempAromaInput.value.toLowerCase(); let list = products.value; if (s) { list = list.filter(p => p.brand.toLowerCase().includes(s) || p.name.toLowerCase().includes(s)); } return list.map(p => ({ brand: p.brand, name: p.name })).slice(0, 50); });

const filteredProducts = computed(() => {
  return products.value.filter(p => {
    const matchesBrand = selectedBrands.value.length === 0 || selectedBrands.value.includes(p.brand);
    const matchesAroma = selectedAromas.value.length === 0 || selectedAromas.value.includes(p.name);
    const matchesGender = activeGender.value === 'ВСЕ' || p.gender === activeGender.value;
    const matchesQuality = activeQuality.value === 'ВСЕ' || p.quality === activeQuality.value;
    const matchesFactory = activeFactory.value === 'ВСЕ' || p.factory.toUpperCase().includes(activeFactory.value);
    const matchesNew = !isNewOnly.value || p.isNew;
    return matchesBrand && matchesAroma && matchesGender && matchesQuality && matchesFactory && matchesNew;
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
  
  const topListFull = [...p]
      .sort((a,b) => { const valA = statsMode.value === '6m' ? a.sales6m : a.salesAll; const valB = statsMode.value === '6m' ? b.sales6m : b.salesAll; return valB - valA; })
      .slice(0, 50);

  const availPerc = Math.round((avail / count) * 100);
  return { 
      total: p.length, countAvail: avail, countOut: out, availability: availPerc, 
      avg50: Math.round(s50 / count), avg500: Math.round(s500 / count), avg1000: Math.round(s1000 / count), 
      qualityPerc: { 'TOP': Math.round((qual['TOP'] / count) * 100), 'Q1': Math.round((qual['Q1'] / count) * 100), 'Q2': Math.round((qual['Q2'] / count) * 100) },
      factoryPerc: { 'LUZI': Math.round((factories['LUZI'] / count) * 100), 'EPS': Math.round((factories['EPS'] / count) * 100), 'SELUZ': Math.round((factories['SELUZ'] / count) * 100) },
      topListFull: topListFull
  }
})

const getSex = (g) => ({ m: 'Муж', w: 'Жен', y: 'Уни' }[g] || '—');
const open = (u) => window.open(u.startsWith('http') ? u : `https://${u}`, '_blank');
onMounted(() => {
  let meta = document.querySelector('meta[name=viewport]');
  if (!meta) {
    meta = document.createElement('meta');
    meta.name = 'viewport';
    document.head.appendChild(meta);
  }
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
/* FONTS */
@font-face { font-family: 'Kollektif'; src: local('Kollektif'), url('https://fonts.cdnfonts.com/s/16912/Kollektif.woff') format('woff'); font-weight: normal; font-style: normal; }
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@100;300;400;700&display=swap');

.eng-font { font-family: 'Kollektif', 'Segoe UI', sans-serif; }
.rus-font { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
.mono { font-family: 'JetBrains Mono', monospace; }

.bahur-terminal {
  --bg: #000; --text: #fff; --border: rgba(255,255,255,0.08); --dim: #555; --green: #00ff88; --red: #ff3b30;
  --panel-bg: rgba(0,0,0,0.95); --aura-bg: rgba(0,0,0,0.4); --aura-text: #fff;
  --sticky-bg: rgba(0,0,0,0.9); 
  --seg-bg: #1c1c1e; --seg-active: #ffffff; --seg-txt: #8e8e93; --seg-txt-active: #000000;
  --btn-ctrl-bg: rgba(255,255,255,0.05);
  min-height: 100vh; background: var(--bg); color: var(--text); font-family: 'Helvetica Neue', sans-serif;
  touch-action: pan-y;
}
.noir { 
  --bg: #000; --text: #fff; --aura-bg: rgba(0,0,0,0.4); 
  --sticky-bg: rgba(0,0,0,0.9); --panel-bg: rgba(0,0,0,0.95);
  --seg-bg: #1c1c1e; --seg-active: #fff; --seg-txt: #8e8e93; --seg-txt-active: #000;
  --btn-ctrl-bg: rgba(255,255,255,0.08);
}
.bahur-terminal:not(.noir) { 
  --bg: #ffffff; --text: #000; --border: rgba(0,0,0,0.1); --dim: #888; 
  --panel-bg: rgba(255,255,255,0.98); --aura-bg: rgba(255,255,255,0.5); --aura-text: #000;
  --sticky-bg: rgba(255,255,255,0.95); --seg-bg: #e5e5ea; --seg-active: #000000; --seg-txt: #8e8e93; --seg-txt-active: #ffffff;
  --btn-ctrl-bg: #f2f2f7; 
}

/* CUSTOM SCROLLBARS */
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: var(--bg); }
::-webkit-scrollbar-thumb { background: var(--text); border-radius: 2px; border: 1px solid var(--bg); }
::-webkit-scrollbar-thumb:hover { background: var(--dim); }

.container { max-width: 1400px; margin: 0 auto; padding: 15px; }

/* LOADING SCREEN */
.loading-overlay { position: fixed; inset: 0; background: var(--bg); z-index: 2000; display: flex; justify-content: center; align-items: center; }
.action-loader { position: relative; text-align: center; }
.thin-hero-text { font-family: 'Kollektif', sans-serif; font-weight: 100; font-size: 60px; color: var(--text); letter-spacing: 5px; opacity: 0; animation: tracking-in 1.2s cubic-bezier(0.215, 0.610, 0.355, 1.000) forwards; }
.scan-line { width: 0; height: 1px; background: var(--text); margin: 10px auto 0; animation: scan-expand 1s cubic-bezier(0.23, 1, 0.32, 1) forwards 0.5s; }
@keyframes tracking-in { 0% { letter-spacing: 20px; opacity: 0; filter: blur(10px); } 100% { letter-spacing: 5px; opacity: 1; filter: blur(0px); } }
@keyframes scan-expand { to { width: 100%; } }

/* ERROR ZONE */
.error-zone { display: flex; justify-content: center; align-items: center; height: 50vh; }
.error-box-noir { text-align: center; border: 1px solid var(--text); padding: 40px 60px; border-radius: 4px; background: var(--bg); box-shadow: 0 0 20px rgba(255,255,255,0.05); max-width: 400px; }
.err-icon { font-size: 30px; margin-bottom: 15px; color: var(--text); opacity: 0.8; }
.err-title { font-size: 14px; color: var(--text); margin-bottom: 10px; letter-spacing: 1px; }
.err-desc { font-size: 12px; color: var(--dim); margin-bottom: 25px; }
.retry-btn-noir { background: var(--text); border: none; color: var(--bg); padding: 12px 24px; font-family: 'JetBrains Mono', monospace; font-size: 11px; cursor: pointer; transition: 0.3s; text-transform: uppercase; font-weight: 700; }
.retry-btn-noir:hover { opacity: 0.8; }

/* CUSTOM SCROLL WIDGET (TRACK) */
.scroll-widget-track {
  position: fixed; right: 2px; top: 0; bottom: 0; width: 20px; z-index: 1000;
  display: flex; justify-content: center; touch-action: none;
}
.scroll-widget-thumb {
  position: absolute; width: 4px; background: var(--text); border-radius: 2px;
  box-shadow: 0 0 8px var(--text); transition: opacity 0.2s;
}
.scroll-widget-track::before {
  content: ''; position: absolute; top: 0; bottom: 0; width: 1px; background: var(--border); opacity: 0.3;
}

/* STICKY NAV */
.sticky-nav-group { position: sticky; top: 0; z-index: 500; background: var(--sticky-bg); backdrop-filter: blur(15px); border-bottom: 1px solid var(--text); margin-bottom: 0; }
.controls-luxury { padding: 12px 0; border-bottom: 0.5px solid var(--border); }

/* CONTROLS LAYOUT - FLEX FOR DESKTOP */
.ctrl-wrapper-desktop { display: flex; justify-content: space-between; align-items: center; width: 100%; }
.left-group { display: flex; gap: 10px; width: auto; align-items: center; }
.right-group { width: auto; }
.control-item { width: auto; min-width: 100px; }

/* BUTTONS */
.main-ctrl-btn { width: 100%; background: var(--btn-ctrl-bg); border: none; color: var(--text); padding: 14px 20px; border-radius: 30px; font-size: 13px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; transition: all 0.2s; letter-spacing: 0.5px; white-space: nowrap; text-transform: none; }
.ctrl-text-bold { font-weight: 700; }
.btn-txt-fixed { max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.main-ctrl-btn:hover { background: rgba(125,125,125,0.15); }
.main-ctrl-btn.active { background: var(--text); color: var(--bg); }
.pill-arrow { width: 10px; height: 10px; opacity: 0.8; } 

.relative-zone { position: relative; }
.click-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 800; background: transparent; }

.bahur-popup-menu { position: absolute; top: 60px; background: var(--panel-bg); border: 0.5px solid var(--border); border-radius: 16px; padding: 15px; box-shadow: 0 30px 60px rgba(0,0,0,0.95); display: flex; flex-direction: column; gap: 10px; z-index: 999; }
.bahur-popup-menu.list-mode { left: 0; transform: none; width: 240px; }
.bahur-popup-menu.filter-mode { right: 0; width: 220px; }

.popup-input { width: 100%; background: var(--seg-bg); border: none; padding: 10px; border-radius: 8px; color: var(--text); font-size: 13px; outline: none; margin-bottom: 5px; box-sizing: border-box; }
.popup-input::placeholder { opacity: 0.5; }
.search-input-box { width: 100%; }
.brands-scroll-area { max-height: 280px; overflow-y: auto; }
.custom-scroll-minimal::-webkit-scrollbar { width: 2px; }
.custom-scroll-minimal::-webkit-scrollbar-thumb { background: var(--dim); }
.brands-list-vertical { display: flex; flex-direction: column; gap: 4px; }
.brand-row-btn { display: flex; justify-content: space-between; align-items: center; background: transparent; color: var(--text); border: none; padding: 10px 10px; border-radius: 6px; cursor: pointer; font-size: 11px; text-transform: capitalize; text-align: left; transition: 0.2s; opacity: 0.8; }
.all-brand-btn { opacity: 1; font-weight: 700; margin-bottom: 5px; border-bottom: 1px solid var(--border); padding-bottom: 10px; border-radius: 0; }
.brand-row-btn:hover { background: var(--seg-bg); opacity: 1; }
.brand-font-fix { font-weight: 900; font-size: 10px; opacity: 0.8; }
.brand-left-group { display: flex; align-items: center; gap: 8px; overflow: hidden; }
.brand-txt-truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 150px; }
.aroma-sug-brand { font-weight: 900; opacity: 0.5; margin-right: 5px; font-size: 10px; }
.aroma-sug-name { font-weight: 700; font-size: 11px; }
.circle-check-icon.left { margin-right: 5px; width: 16px; height: 16px; }
.check-status.right { width: 14px; height: 14px; }

.popup-section { margin-bottom: 5px; }
.popup-label { display: block; font-size: 8px; font-weight: 700; color: var(--dim); margin-bottom: 4px; letter-spacing: 1px; }
.segmented-control { display: flex; background: var(--seg-bg); padding: 3px; border-radius: 8px; }
.segment-btn { flex: 1; background: transparent; border: none; color: var(--seg-txt); padding: 5px 0; font-size: 10px; font-weight: 600; border-radius: 6px; cursor: pointer; transition: 0.2s; }
.segment-btn.active { background: var(--seg-active); color: var(--seg-txt-active); box-shadow: 0 2px 5px rgba(0,0,0,0.1); font-weight: 700; }
.arrows-horn { font-size: 10px; letter-spacing: 0; display: inline-flex; gap: 2px; } 
.pop-enter-active, .pop-leave-active { transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1); }
.pop-enter-from, .pop-leave-to { opacity: 0; transform: translateY(-10px) scale(0.95); }

.dash-collapsible-wrapper { display: grid; grid-template-rows: 0fr; transition: grid-template-rows 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
.dash-collapsible-wrapper.open { grid-template-rows: 1fr; }
.dash-inner-content { overflow: hidden; }

.dashboard { margin-bottom: 20px; }
.dash-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 10px; }
.stat-card { border: 0.5px solid var(--border); padding: 18px; background: var(--bg); border-left: 3.5px solid var(--text); }
.d-label { display: block; font-size: 8px; font-weight: 700; color: var(--dim); margin-bottom: 12px; letter-spacing: 1.5px; text-transform: uppercase; font-family: 'Helvetica Neue', sans-serif; }
.stat-card .v { font-size: 24px; font-weight: 700; }
.responsive-text { font-size: clamp(10px, 1.1vw, 14px); }
.avg-row { margin-bottom: 4px; color: var(--dim); }
.avg-row .val { color: var(--text); font-weight: 700; margin-left: 2px; }
.q-row-stacked, .stock-box-stacked { margin-bottom: 10px; }
.q-meta { display: flex; justify-content: space-between; font-size: 9px; font-weight: 600; margin-bottom: 5px; }
.op-5 { opacity: 0.5; }
.q-track-neon { height: 2px; background: var(--border); width: 100%; overflow: hidden; }
.q-fill-neon { height: 100%; background: var(--text); box-shadow: 0 0 5px var(--text); transition: 1s ease-out; }
.white-part { background: #fff; box-shadow: 0 0 5px #fff; } 
.v-small { font-size: 16px; font-weight: 700; margin-bottom: 5px; }
.mini-stat-row { font-size: 9px; font-weight: 700; margin-top: 5px; }
.dim-slash { margin: 0 5px; opacity: 0.3; }

/* CARD 1: SPLIT AROMAS + PRICE */
.split-top-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 20px; }
.st-item { flex: 1; }
.st-sep { width: 1px; background: var(--border); margin: 0 10px; opacity: 0.5; align-self: stretch; }
.st-price-box { flex: 1.5; }
.avg-price-flex { display: flex; flex-direction: column; gap: 4px; }
.ap-item { font-family: 'JetBrains Mono', monospace; font-size: 11px; color: var(--dim); }
.ap-item .val { color: var(--text); font-weight: 700; font-size: 12px; margin-left: 5px; }

/* CARD 2: STOCK */
.stock-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 5px; }
.mb-1 { margin-bottom: 8px; }
.center-text { text-align: center; }

/* COMPACT TOP LIST STYLES (DARK SCROLLBAR) */
.top-row-flex { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; }
.mode-switch { background: none; border: 1px solid var(--border); color: var(--text); cursor: pointer; border-radius: 4px; font-size: 10px; padding: 2px 5px; }
.top-list-scroll-container { max-height: 60px; overflow-y: auto; display: flex; flex-direction: column; gap: 4px; padding-right: 0px; }
/* Dark Scrollbar for Top List */
.custom-scroll-minimal::-webkit-scrollbar { width: 3px; }
.custom-scroll-minimal::-webkit-scrollbar-track { background: transparent; }
.custom-scroll-minimal::-webkit-scrollbar-thumb { background: #222; border-radius: 4px; } /* Dark Grey */

.top-row-compact { display: flex; justify-content: space-between; align-items: center; font-size: 10px; padding: 2px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }
.tr-left-main { display: flex; align-items: center; width: 40%; overflow: hidden; }
.top-num { color: var(--dim); margin-right: 5px; font-size: 9px; min-width: 12px; }
.top-name { overflow: hidden; white-space: nowrap; text-overflow: ellipsis; font-weight: 500; font-size: 10px; }
.tr-mid-graph { flex-grow: 1; margin: 0 8px; display: flex; align-items: center; }
.mini-bar-track { width: 100%; height: 2px; background: var(--border); overflow: hidden; }
.mini-bar-fill { height: 100%; background: var(--text); box-shadow: 0 0 4px var(--text); }
.tr-right-meta { display: flex; align-items: center; gap: 4px; }
.badge-mini { border: 1px solid var(--border); padding: 1px 3px; font-size: 8px; color: var(--text); opacity: 0.8; border-radius: 2px; }
.top-val { font-weight: 700; margin-left: 4px; font-size: 9px; min-width: 25px; text-align: right; }

.grid-table { display: flex; flex-direction: column; width: 100%; min-width: 1000px; border: 0.5px solid var(--border); border-top: none; }
.grid-layout-def { display: grid; grid-template-columns: 60px 1fr 80px 120px 120px calc(var(--p-cols) * 80px); align-items: center; box-sizing: border-box; width: 100%; }
.grid-layout-def.head { border-bottom: none; background: transparent; }
.grid-layout-def:not(.head) { background: var(--bg); border-bottom: 0.5px solid var(--border); position: relative; overflow: hidden; }
.cell { height: 100%; display: flex; align-items: center; padding: 15px; border-right: 0.5px solid var(--border); box-sizing: border-box; overflow: hidden; }
.head-txt { font-size: 8px; font-weight: 700; color: var(--dim); text-transform: uppercase; letter-spacing: 1.5px; font-family: 'Helvetica Neue', sans-serif;}
.center { justify-content: center; text-align: center; }
.row-visual-layer { display: contents; }
.clickable-row { cursor: pointer; transition: 0.3s; }
.out { opacity: 0.5; }
.badge-new-box { background: var(--text); color: var(--bg); font-size: 8px; font-weight: 800; padding: 1px 3px; border-radius: 2px; margin: 2px auto 0; display: inline-block; }
.desk-only-new { display: inline-block; }
.lamp-sq { width: 14px; height: 3px; margin: 0 auto; border-radius: 1px; transition: 0.3s; }
.lamp-sq.green { background: #00ff41; box-shadow: 0 0 8px #00ff41, 0 0 4px #00ff41; opacity: 1; }
.lamp-sq.red { background: #ff2a2a; box-shadow: 0 0 8px #ff2a2a, 0 0 4px #ff2a2a; opacity: 1; }
.lamp-sq.standard { background: var(--text); box-shadow: 0 0 8px var(--text), 0 0 3px var(--text); opacity: 1; }
.badge-square-matte { font-size: 9px; font-weight: 700; border: 0.5px solid var(--border); padding: 5px 12px; letter-spacing: 1px; text-transform: uppercase; margin: 0 auto; color: var(--text); opacity: 0.8; font-family: 'Kollektif', sans-serif;}
.m-square-matte { font-size: 8px; font-weight: 700; border: 0.5px solid var(--border); padding: 2px 6px; opacity: 0.7; text-transform: uppercase; }
.id-zone-square { flex-direction: column; gap: 5px; justify-content: center; border-right: 0.5px solid var(--border); padding: 8px 0; }
.id-sq-top { font-size: 14px; font-weight: 900; color: var(--dim); }
.scent-info { width: 100%; padding-left: 10px; }
.brand-code { font-size: 10px; font-weight: 700; opacity: 0.5; display: block; text-transform: uppercase; letter-spacing: 1px; }
.scent-title { font-size: 17px; font-weight: 500; line-height: 1.2; letter-spacing: 0.5px; }
.mobile-only-meta { display: none; margin-top: 8px; gap: 5px; align-items: center; }
.new-mobile { display: block; background: var(--text); color: var(--bg); border: none; font-weight: 900; }
.price-container { width: calc(var(--p-cols) * 80px); }
.price-section { display: grid; height: 100%; width: 100%; align-items: center; transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
.p-col { text-align: center; font-size: 15px; height: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden; white-space: nowrap; box-sizing: border-box; }
.p-col.line { border-right: 0.5px solid var(--border); }
.head-p .p-col { font-size: 8px; font-weight: 700; color: var(--dim); letter-spacing: 1.5px; text-transform: uppercase; }
.row-aura-overlay { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; opacity: 0; backdrop-filter: blur(0px); background: transparent; transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); z-index: 10; pointer-events: none; }
.clickable-row:hover .row-aura-overlay, .clickable-row.simulated-hover .row-aura-overlay { opacity: 1; backdrop-filter: blur(8px); background: var(--aura-bg); }
.clickable-row:active .row-aura-overlay { opacity: 0 !important; backdrop-filter: none !important; }
.aura-text { font-size: 11px; font-weight: 900; letter-spacing: 5px; color: var(--aura-text); transform: translateY(15px); opacity: 0; transition: 0.5s; font-family: 'Kollektif', sans-serif; }
.clickable-row:hover .aura-text, .clickable-row.simulated-hover .aura-text { opacity: 1; transform: translateY(0); }
.clickable-row:active .aura-text { opacity: 0 !important; }

@media (max-width: 900px) {
  .dash-grid { grid-template-columns: 1fr 1fr; }
  .span-full { grid-column: span 2; } 
  .grid-table { min-width: 100%; border: none; }
  .cell { border-right: none; }
  .desk-only { display: none; }
  .mobile-only-meta { display: flex; }
  .grid-layout-def { grid-template-columns: 30px 1fr calc(var(--p-cols) * 55px); border-bottom: 0.5px solid var(--border); }
  .id-zone-square { border-right: none; padding: 2px 0 !important; align-items: center; justify-content: flex-start; padding-top: 15px !important; }
  .id-sq-top { font-size: 10px; margin-bottom: 4px; }
  .lamp-sq { width: 6px; height: 6px; border-radius: 50%; }
  .border-right-mobile { border-right: 0.5px solid var(--border) !important; padding-right: 5px; }
  .scent-info { padding-left: 2px; }
  .scent-title { font-size: 13px; }
  .price-container { width: calc(var(--p-cols) * 55px); }
  .price-section { border-right: none; }
  .p-col { padding: 0; font-size: 12px; border-right: 0.5px solid var(--border) !important; }
  .p-col.last { border-right: none !important; }
  .aura-text { font-size: 9px; letter-spacing: 2px; }
  
  /* MOBILE CONTROL LAYOUT */
  .ctrl-wrapper-desktop { display: grid; grid-template-columns: repeat(4, 1fr); gap: 5px; }
  .left-group { display: contents; }
  .right-group { display: contents; }
  .control-item { min-width: 0; width: 100%; }
  
  /* MOBILE BUTTON STYLING (Larger, Bolder) */
  .main-ctrl-btn { 
    font-size: 11px; 
    padding: 18px 0; /* Taller buttons */
    font-weight: 800; /* Bolder text */
    border-radius: 12px; /* Smoother */
  }
  .btn-txt-fixed { max-width: 65px; }
  
  .desk-only-new { display: none; }
  .bahur-popup-menu.list-mode { left: 0 !important; right: 0 !important; margin: auto !important; transform: none !important; width: 220px !important; }
  .custom-scroll-minimal::-webkit-scrollbar { width: 1px !important; }
  .container { padding-right: 35px; }
}
</style>
