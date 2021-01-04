local char, byte, pairs, floor = string.char, string.byte, pairs, math.floor
local table_insert, table_concat = table.insert, table.concat
local unpack = table.unpack or unpack

local function unicode_to_utf8(code)
   -- converts numeric UTF code (U+code) to UTF-8 string
   local t, h = {}, 128
   while code >= h do
      t[#t+1] = 128 + code%64
      code = floor(code/64)
      h = h > 32 and 32 or h/2
   end
   t[#t+1] = 256 - 2*h + code
   return char(unpack(t)):reverse()
end

local function utf8_to_unicode(utf8str, pos)
   -- pos = starting byte position inside input string (default 1)
   pos = pos or 1
   local code, size = utf8str:byte(pos), 1
   if code >= 0xC0 and code < 0xFE then
      local mask = 64
      code = code - 128
      repeat
         local next_byte = utf8str:byte(pos + size) or 0
         if next_byte >= 0x80 and next_byte < 0xC0 then
            code, size = (code - mask - 2) * 64 + next_byte, size + 1
         else
            code, size = utf8str:byte(pos), 1
         end
         mask = mask * 32
      until code < mask
   end
   -- returns code, number of bytes in this utf8 char
   return code, size
end

local map_1256_to_unicode = {
   [0x80] = 0x20AC,
   [0x81] = 0x067E,
   [0x82] = 0x201A,
   [0x83] = 0x0192,
   [0x84] = 0x201E,
   [0x85] = 0x2026,
   [0x86] = 0x2020,
   [0x87] = 0x2021,
   [0x88] = 0x02C6,
   [0x89] = 0x2030,
   [0x8A] = 0x0679,
   [0x8B] = 0x2039,
   [0x8C] = 0x0152,
   [0x8D] = 0x0686,
   [0x8E] = 0x0698,
   [0x8F] = 0x0688,
   [0x90] = 0x06AF,
   [0x91] = 0x2018,
   [0x92] = 0x2019,
   [0x93] = 0x201C,
   [0x94] = 0x201D,
   [0x95] = 0x2022,
   [0x96] = 0x2013,
   [0x97] = 0x2014,
   [0x98] = 0x06A9,
   [0x99] = 0x2122,
   [0x9A] = 0x0691,
   [0x9B] = 0x203A,
   [0x9C] = 0x0153,
   [0x9D] = 0x200C,
   [0x9E] = 0x200D,
   [0x9F] = 0x06BA,
   [0xA0] = 0x00A0,
   [0xA1] = 0x060C,
   [0xA2] = 0x00A2,
   [0xA3] = 0x00A3,
   [0xA4] = 0x00A4,
   [0xA5] = 0x00A5,
   [0xA6] = 0x00A6,
   [0xA7] = 0x00A7,
   [0xA8] = 0x00A8,
   [0xA9] = 0x00A9,
   [0xAA] = 0x06BE,
   [0xAB] = 0x00AB,
   [0xAC] = 0x00AC,
   [0xAD] = 0x00AD,
   [0xAE] = 0x00AE,
   [0xAF] = 0x00AF,
   [0xB0] = 0x00B0,
   [0xB1] = 0x00B1,
   [0xB2] = 0x00B2,
   [0xB3] = 0x00B3,
   [0xB4] = 0x00B4,
   [0xB5] = 0x00B5,
   [0xB6] = 0x00B6,
   [0xB7] = 0x00B7,
   [0xB8] = 0x00B8,
   [0xB9] = 0x00B9,
   [0xBA] = 0x061B,
   [0xBB] = 0x00BB,
   [0xBC] = 0x00BC,
   [0xBD] = 0x00BD,
   [0xBE] = 0x00BE,
   [0xBF] = 0x061F,
   [0xC0] = 0x06C1,
   [0xC1] = 0x0621,
   [0xC2] = 0x0622,
   [0xC3] = 0x0623,
   [0xC4] = 0x0624,
   [0xC5] = 0x0625,
   [0xC6] = 0x0626,
   [0xC7] = 0x0627,
   [0xC8] = 0x0628,
   [0xC9] = 0x0629,
   [0xCA] = 0x062A,
   [0xCB] = 0x062B,
   [0xCC] = 0x062C,
   [0xCD] = 0x062D,
   [0xCE] = 0x062E,
   [0xCF] = 0x062F,
   [0xD0] = 0x0630,
   [0xD1] = 0x0631,
   [0xD2] = 0x0632,
   [0xD3] = 0x0633,
   [0xD4] = 0x0634,
   [0xD5] = 0x0635,
   [0xD6] = 0x0636,
   [0xD7] = 0x00D7,
   [0xD8] = 0x0637,
   [0xD9] = 0x0638,
   [0xDA] = 0x0639,
   [0xDB] = 0x063A,
   [0xDC] = 0x0640,
   [0xDD] = 0x0641,
   [0xDE] = 0x0642,
   [0xDF] = 0x0643,
   [0xE0] = 0x00E0,
   [0xE1] = 0x0644,
   [0xE2] = 0x00E2,
   [0xE3] = 0x0645,
   [0xE4] = 0x0646,
   [0xE5] = 0x0647,
   [0xE6] = 0x0648,
   [0xE7] = 0x00E7,
   [0xE8] = 0x00E8,
   [0xE9] = 0x00E9,
   [0xEA] = 0x00EA,
   [0xEB] = 0x00EB,
   [0xEC] = 0x0649,
   [0xED] = 0x064A,
   [0xEE] = 0x00EE,
   [0xEF] = 0x00EF,
   [0xF0] = 0x064B,
   [0xF1] = 0x064C,
   [0xF2] = 0x064D,
   [0xF3] = 0x064E,
   [0xF4] = 0x00F4,
   [0xF5] = 0x064F,
   [0xF6] = 0x0650,
   [0xF7] = 0x00F7,
   [0xF8] = 0x0651,
   [0xF9] = 0x00F9,
   [0xFA] = 0x0652,
   [0xFB] = 0x00FB,
   [0xFC] = 0x00FC,
   [0xFD] = 0x200E,
   [0xFE] = 0x200F,
   [0xFF] = 0x06D2,
}
local map_unicode_to_1256 = {}
for code1256, code in pairs(map_1256_to_unicode) do
   map_unicode_to_1256[code] = code1256
end

function string.fromutf8(utf8str)
   local pos, result_1256 = 1, {}
   while pos <= #utf8str do
      local code, size = utf8_to_unicode(utf8str, pos)
      pos = pos + size
      code = code < 128 and code or map_unicode_to_1256[code] or ('?'):byte()
      table_insert(result_1256, char(code))
   end
   return table_concat(result_1256)
end

function string.toutf8(str1256)
   local result_utf8 = {}
   for pos = 1, #str1256 do
      local code = str1256:byte(pos)
      table_insert(result_utf8, unicode_to_utf8(map_1256_to_unicode[code] or code))
   end
   return table_concat(result_utf8)
end
