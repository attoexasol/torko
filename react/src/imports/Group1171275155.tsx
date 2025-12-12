import svgPaths from "./svg-r218mbjjro";

function Menu() {
  return (
    <div className="absolute bottom-[29.09%] left-0 right-[94.05%] top-[29.09%]" data-name="menu">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 23 23">
        <g id="menu">
          <path d={svgPaths.p2c80bf80} id="Vector" stroke="var(--stroke-0, black)" strokeWidth="1.5" />
          <path d={svgPaths.p1bf3a200} id="Vector_2" stroke="var(--stroke-0, black)" strokeWidth="1.5" />
          <path d={svgPaths.p37b8b000} id="Vector_3" stroke="var(--stroke-0, black)" strokeWidth="1.5" />
          <path d={svgPaths.p1aa6a480} id="Vector_4" stroke="var(--stroke-0, black)" strokeWidth="1.5" />
        </g>
      </svg>
    </div>
  );
}

function Group() {
  return (
    <div className="absolute bottom-[29.09%] contents left-0 right-[94.05%] top-[29.09%]">
      <Menu />
    </div>
  );
}

function SmsNotification() {
  return (
    <div className="absolute inset-[27.27%_7.22%_29.09%_86.36%]" data-name="sms-notification">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 25 24">
        <g id="sms-notification">
          <path d={svgPaths.p2a97a280} id="Vector" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeMiterlimit="10" strokeWidth="1.5" />
          <path d={svgPaths.p249f6e2a} id="Vector_2" stroke="var(--stroke-0, white)" strokeLinecap="round" strokeLinejoin="round" strokeMiterlimit="10" strokeWidth="1.5" />
          <path d={svgPaths.p18e6f000} fill="var(--fill-0, white)" id="Vector_3" />
          <g id="Vector_4" opacity="0"></g>
        </g>
      </svg>
    </div>
  );
}

function Group1() {
  return (
    <div className="absolute contents left-[227.5px] top-0">
      <div className="absolute bg-neutral-50 h-[55px] left-[227.5px] rounded-[28px] top-0 w-[157.5px]" />
      <div className="absolute bg-[#d6775c] h-[49px] left-[306.76px] rounded-[28px] top-[3px] w-[75.147px]" />
      <SmsNotification />
    </div>
  );
}

function IconsOutlineSearch() {
  return (
    <div className="absolute h-[34px] left-[255.29px] top-[11px] w-[35px]" data-name="Icons/Outline/Search">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 35 34">
        <g id="Icons/Outline/Search">
          <path clipRule="evenodd" d={svgPaths.p249c4b00} fill="var(--fill-0, #8E8E8E)" fillRule="evenodd" id="Shape" />
        </g>
      </svg>
    </div>
  );
}

function Group2() {
  return (
    <div className="absolute contents left-[227.5px] top-0">
      <Group1 />
      <IconsOutlineSearch />
    </div>
  );
}

export default function Group3() {
  return (
    <div className="relative size-full">
      <Group />
      <p className="absolute font-['Roboto:Medium',sans-serif] font-medium leading-[18px] left-[10.16%] right-[77.54%] text-[18px] text-black top-[calc(50%-9.5px)] tracking-[-0.1px]" style={{ fontVariationSettings: "'wdth' 100" }}>
        LOGO
      </p>
      <Group2 />
    </div>
  );
}