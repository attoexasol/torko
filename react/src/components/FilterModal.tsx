import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import svgPaths from "../imports/svg-s9uo9hrtnm";

interface FilterModalProps {
  isOpen: boolean;
  onClose: () => void;
  language?: 'bn' | 'en';
  onApplyFilters?: (filters: FilterState) => void;
}

interface FilterState {
  area: string;
  service: string;
  timeRange: 'today' | 'thisWeek';
}

export const FilterModal: React.FC<FilterModalProps> = ({
  isOpen,
  onClose,
  language = 'bn',
  onApplyFilters
}) => {
  const [filters, setFilters] = useState<FilterState>({
    area: 'All',
    service: 'All',
    timeRange: 'thisWeek'
  });

  const [areaDropdownOpen, setAreaDropdownOpen] = useState(false);
  const [serviceDropdownOpen, setServiceDropdownOpen] = useState(false);

  const areaOptions = ['All', 'Near Me', 'Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna'];
  const serviceOptions = ['All', 'Emergency', 'Technology', 'Education', 'Sports', 'Culture', 'Business', 'Youth', 'Transport', 'Agriculture', 'Events', 'Environment'];

  const t = {
    filterBy: language === 'bn' ? 'Filter by:' : 'Filter by:',
    selectArea: language === 'bn' ? 'Select Area' : 'Select Area',
    nearMe: language === 'bn' ? 'Near Me' : 'Near Me',
    otherServices: language === 'bn' ? 'Other Services' : 'Other Services',
    emergency: language === 'bn' ? 'Emergency' : 'Emergency',
    showStatsFor: language === 'bn' ? 'Show Stats For' : 'Show Stats For',
    today: language === 'bn' ? 'Today' : 'Today',
    thisWeek: language === 'bn' ? 'This Week' : 'This Week',
    reset: language === 'bn' ? 'Reset' : 'Reset',
    resetAll: language === 'bn' ? 'Reset All' : 'Reset All',
    applyFilters: language === 'bn' ? 'Apply Filters(3)' : 'Apply Filters(3)',
  };

  const handleReset = (section: 'area' | 'service' | 'time') => {
    if (section === 'area') {
      setFilters({ ...filters, area: 'Near Me' });
    } else if (section === 'service') {
      setFilters({ ...filters, service: 'Emergency' });
    } else if (section === 'time') {
      setFilters({ ...filters, timeRange: 'today' });
    }
  };

  const handleResetAll = () => {
    setFilters({
      area: 'Near Me',
      service: 'Emergency',
      timeRange: 'today'
    });
  };

  const handleApplyFilters = () => {
    if (onApplyFilters) {
      onApplyFilters(filters);
    }
    onClose();
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 bg-black/30 backdrop-blur-sm z-40"
            onClick={onClose}
          />

          {/* Filter Modal */}
          <motion.div
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] bg-white dark:bg-card rounded-t-[18px] shadow-2xl z-50 px-[22px] pt-[14px] pb-[54px]"
          >
            {/* Handle */}
            <div className="w-[34px] h-[5px] bg-[#d9d9d9] dark:bg-[#3a3a3a] rounded-[9px] mx-auto mb-[27px]" />

            {/* Content */}
            <div className="flex flex-col gap-[27px] w-full">
              {/* Filter by text */}
              <p className="font-['Roboto:Medium',sans-serif] text-[13.5px] text-[#555e67] dark:text-[#9e9e9e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                {t.filterBy}
              </p>

              {/* Select Area */}
              <div className="flex flex-col gap-[18px] w-full">
                <div className="flex items-center justify-between">
                  <p className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#31373d] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {t.selectArea}
                  </p>
                  <button
                    onClick={() => handleReset('area')}
                    className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#d6775c]"
                    style={{ fontVariationSettings: "'wdth' 100" }}
                  >
                    {t.reset}
                  </button>
                </div>

                {/* Area Dropdown */}
                <div className="relative">
                  <button
                    onClick={() => setAreaDropdownOpen(!areaDropdownOpen)}
                    className="bg-neutral-50 dark:bg-[#0d3a4a] h-[54px] rounded-[14px] border border-[#ecedf0] dark:border-[#0d3a4a] px-[6px] flex items-center justify-between w-full"
                  >
                    <div className="flex items-center gap-[11px] px-[9px]">
                      <div className="w-[9px] h-[9px] rounded-full bg-[#25A259]" />
                      <p className="font-['Roboto:Medium',sans-serif] text-[14px] text-[#555e67] dark:text-[#9e9e9e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                        {filters.area}
                      </p>
                    </div>
                    <div className="w-[42px] h-[42px] bg-[#efefef] dark:bg-[#104050] rounded-[8px] flex items-center justify-center">
                      <svg className="w-[11px] h-[6px]" viewBox="0 0 13 8" fill="none">
                        <path d={svgPaths.p2bb200c0} stroke="#555E67" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    </div>
                  </button>

                  {/* Area Dropdown Options */}
                  <AnimatePresence>
                    {areaDropdownOpen && (
                      <motion.div
                        initial={{ opacity: 0, y: -10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        transition={{ duration: 0.2 }}
                        className="absolute top-[58px] left-0 right-0 bg-white dark:bg-[#2a2a2a] border border-[#ecedf0] dark:border-[#333333] rounded-[14px] shadow-lg z-50 max-h-[200px] overflow-y-auto"
                      >
                        {areaOptions.map((area) => (
                          <button
                            key={area}
                            onClick={() => {
                              setFilters({ ...filters, area });
                              setAreaDropdownOpen(false);
                            }}
                            className={`w-full px-[20px] py-[12px] text-left hover:bg-neutral-50 dark:hover:bg-[#333333] transition-colors ${
                              filters.area === area ? 'bg-[#f3f0ff] dark:bg-[#3a3a3a]' : ''
                            }`}
                          >
                            <p className={`font-['Roboto:Medium',sans-serif] text-[14px] ${filters.area === area ? 'text-[#d6775c]' : 'text-[#555e67] dark:text-[#9e9e9e]'}`} style={{ fontVariationSettings: "'wdth' 100" }}>
                              {area}
                            </p>
                          </button>
                        ))}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>

                {/* Divider */}
                <div className="h-[1px] bg-[#ecedf0] dark:bg-[#333333] w-full" />
              </div>

              {/* Other Services */}
              <div className="flex flex-col gap-[18px] w-full">
                <div className="flex items-center justify-between">
                  <p className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#31373d] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {t.otherServices}
                  </p>
                  <button
                    onClick={() => handleReset('service')}
                    className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#d6775c]"
                    style={{ fontVariationSettings: "'wdth' 100" }}
                  >
                    {t.reset}
                  </button>
                </div>

                {/* Service Dropdown */}
                <div className="relative">
                  <button
                    onClick={() => setServiceDropdownOpen(!serviceDropdownOpen)}
                    className="bg-neutral-50 dark:bg-[#2a2a2a] h-[54px] rounded-[14px] border border-[#ecedf0] dark:border-[#333333] px-[6px] flex items-center justify-between w-full"
                  >
                    <div className="flex items-center gap-[11px] px-[9px]">
                      <p className="font-['Roboto:Medium',sans-serif] text-[14px] text-[#555e67] dark:text-[#9e9e9e]" style={{ fontVariationSettings: "'wdth' 100" }}>
                        {filters.service}
                      </p>
                    </div>
                    <div className="w-[42px] h-[42px] bg-[#efefef] dark:bg-[#3a3a3a] rounded-[8px] flex items-center justify-center">
                      <svg className="w-[11px] h-[6px]" viewBox="0 0 13 8" fill="none">
                        <path d={svgPaths.p2bb200c0} stroke="#555E67" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    </div>
                  </button>

                  {/* Service Dropdown Options */}
                  <AnimatePresence>
                    {serviceDropdownOpen && (
                      <motion.div
                        initial={{ opacity: 0, y: -10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -10 }}
                        transition={{ duration: 0.2 }}
                        className="absolute top-[58px] left-0 right-0 bg-white dark:bg-[#2a2a2a] border border-[#ecedf0] dark:border-[#333333] rounded-[14px] shadow-lg z-50 max-h-[200px] overflow-y-auto"
                      >
                        {serviceOptions.map((service) => (
                          <button
                            key={service}
                            onClick={() => {
                              setFilters({ ...filters, service });
                              setServiceDropdownOpen(false);
                            }}
                            className={`w-full px-[20px] py-[12px] text-left hover:bg-neutral-50 dark:hover:bg-[#333333] transition-colors ${
                              filters.service === service ? 'bg-[#f3f0ff] dark:bg-[#3a3a3a]' : ''
                            }`}
                          >
                            <p className={`font-['Roboto:Medium',sans-serif] text-[14px] ${filters.service === service ? 'text-[#d6775c]' : 'text-[#555e67] dark:text-[#9e9e9e]'}`} style={{ fontVariationSettings: "'wdth' 100" }}>
                              {service}
                            </p>
                          </button>
                        ))}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>

                {/* Divider */}
                <div className="h-[1px] bg-[#ecedf0] dark:bg-[#333333] w-full" />
              </div>

              {/* Show Stats For */}
              <div className="flex flex-col gap-[18px] w-full">
                <div className="flex items-center justify-between">
                  <p className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#31373d] dark:text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {t.showStatsFor}
                  </p>
                  <button
                    onClick={() => handleReset('time')}
                    className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#d6775c]"
                    style={{ fontVariationSettings: "'wdth' 100" }}
                  >
                    {t.reset}
                  </button>
                </div>

                {/* Time Range Options */}
                <div className="flex gap-[11px] w-full">
                  <button
                    onClick={() => setFilters({ ...filters, timeRange: 'today' })}
                    className={`flex-1 h-[54px] rounded-[14px] flex items-center justify-center ${
                      filters.timeRange === 'today'
                        ? 'border-2 border-[#d6775c] bg-white dark:bg-[#2a2a2a]'
                        : 'border border-[#ecedf0] dark:border-[#333333] bg-white dark:bg-[#2a2a2a]'
                    }`}
                  >
                    {filters.timeRange === 'today' && (
                      <svg className="w-[11px] h-[9px] mr-[9px]" viewBox="0 0 13 11" fill="none">
                        <path d={svgPaths.p355cfcd8} stroke="#D6775C" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    )}
                    <p className={`font-['Roboto:SemiBold',sans-serif] text-[14px] ${filters.timeRange === 'today' ? 'text-[#d6775c]' : 'text-[#555e67] dark:text-[#9e9e9e]'}`} style={{ fontVariationSettings: "'wdth' 100" }}>
                      {t.today}
                    </p>
                  </button>

                  <button
                    onClick={() => setFilters({ ...filters, timeRange: 'thisWeek' })}
                    className={`flex-1 h-[54px] rounded-[14px] flex items-center justify-center gap-[9px] ${
                      filters.timeRange === 'thisWeek'
                        ? 'border-2 border-[#d6775c] bg-white dark:bg-[#2a2a2a]'
                        : 'border border-[#ecedf0] dark:border-[#333333] bg-white dark:bg-[#2a2a2a]'
                    }`}
                  >
                    {filters.timeRange === 'thisWeek' && (
                      <svg className="w-[11px] h-[9px]" viewBox="0 0 13 11" fill="none">
                        <path d={svgPaths.p355cfcd8} stroke="#D6775C" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    )}
                    <p className={`font-['Roboto:SemiBold',sans-serif] text-[14px] ${filters.timeRange === 'thisWeek' ? 'text-[#d6775c]' : 'text-[#555e67] dark:text-[#9e9e9e]'}`} style={{ fontVariationSettings: "'wdth' 100" }}>
                      {t.thisWeek}
                    </p>
                  </button>
                </div>

                {/* Divider */}
                <div className="h-[1px] bg-[#ecedf0] dark:bg-[#333333] w-full" />
              </div>

              {/* Action Buttons */}
              <div className="flex gap-[18px] w-full">
                <button
                  onClick={handleResetAll}
                  className="flex-1 bg-[#f3f0ff] dark:bg-[#2a2a2a] rounded-[8px] h-[58px] flex items-center justify-center"
                >
                  <p className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-[#d6775c]" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {t.resetAll}
                  </p>
                </button>

                <button
                  onClick={handleApplyFilters}
                  className="flex-1 bg-[#d6775c] rounded-[8px] h-[58px] flex items-center justify-center"
                >
                  <p className="font-['Roboto:SemiBold',sans-serif] text-[16px] text-white" style={{ fontVariationSettings: "'wdth' 100" }}>
                    {t.applyFilters}
                  </p>
                </button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};