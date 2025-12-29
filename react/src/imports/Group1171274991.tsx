import svgPaths from "./svg-odtz1b9mtt";

function SiChatLine() {
  return (
    <div className="absolute left-[92px] size-[24px] top-[14px]" data-name="si:chat-line">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 24 24">
        <g id="si:chat-line">
          <path d={svgPaths.p19e6bf80} id="Vector" stroke="var(--stroke-0, white)" strokeLinejoin="round" strokeMiterlimit="10" strokeWidth="1.5" />
        </g>
      </svg>
    </div>
  );
}

function Group1() {
  return (
    <div className="absolute contents left-[89px] top-[14px]">
      <p className="absolute font-['Roboto:Bold',sans-serif] font-bold leading-[18px] left-[22.94%] right-[70.1%] text-[13px] text-nowrap text-white top-[calc(50%+3px)] tracking-[-0.1px] whitespace-pre" style={{ fontVariationSettings: "'wdth' 100" }}>
        Chat
      </p>
      <SiChatLine />
    </div>
  );
}

function Group2() {
  return (
    <div className="absolute contents left-[5px] top-[5px]">
      <div className="absolute bg-[#d6775c] inset-[7.14%_47.16%_7.14%_1.29%] rounded-[10px]" data-name="Rectangle" />
      <Group1 />
    </div>
  );
}

function FluentCall20Regular() {
  return (
    <div className="absolute left-[297px] size-[20px] top-[17px]" data-name="fluent:call-20-regular">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 20 20">
        <g id="fluent:call-20-regular">
          <path d={svgPaths.p2e2afc58} fill="var(--fill-0, #9D9D9D)" id="Vector" />
        </g>
      </svg>
    </div>
  );
}

function Group() {
  return (
    <div className="absolute contents left-[295px] top-[17px]">
      <div className="absolute flex flex-col font-['Roboto:Bold',sans-serif] font-bold justify-center leading-[0] left-[76.03%] right-[18.04%] text-[#9d9d9d] text-[13px] text-nowrap top-[calc(50%+16px)] tracking-[-0.1px] translate-y-[-50%]" style={{ fontVariationSettings: "'wdth' 100" }}>
        <p className="leading-[2px] whitespace-pre">Call</p>
      </div>
      <FluentCall20Regular />
    </div>
  );
}

export default function Group3() {
  return (
    <div className="relative size-full">
      <div className="absolute bg-neutral-50 h-[70px] left-1/2 rounded-[15px] top-0 translate-x-[-50%] w-[388px]" />
      <Group2 />
      <Group />
    </div>
  );
}