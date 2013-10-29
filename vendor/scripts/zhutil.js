window.require.register("zhutil", function(exports, require, module) {
var zhnumber, zhnumberformal, zhmap, res$, i$, len$, i, c, zhwordmap, ref$, zhmap10, commitword, parseZHNumber;
zhnumber = ['○', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
zhnumberformal = ['零', '壹', '貳', '參', '肆', '伍', '陸', '柒', '捌', '玖'];
res$ = {};
for (i$ = 0, len$ = zhnumber.length; i$ < len$; ++i$) {
  i = i$;
  c = zhnumber[i$];
  res$[c] = i;
}
zhmap = res$;
zhwordmap = (ref$ = (function(){
  var i$, ref$, len$, results$ = {};
  for (i$ = 0, len$ = (ref$ = zhnumber).length; i$ < len$; ++i$) {
    i = i$;
    c = ref$[i$];
    results$[zhnumberformal[i]] = c;
  }
  return results$;
}()), ref$['０'] = '○', ref$['兩'] = '二', ref$['拾'] = '十', ref$['佰'] = '百', ref$['仟'] = '千', ref$);
zhmap10 = {
  '十': 10,
  '百': 100,
  '千': 1000,
  '萬': 10000,
  '億': Math.pow(10, 8),
  '兆': Math.pow(10, 12)
};
commitword = ['萬', '億', '兆'];
parseZHNumber = function(number){
  var result, buffer, tmp, i$, ref$, len$, digit;
  result = 0;
  buffer = 0;
  tmp = 0;
  for (i$ = 0, len$ = (ref$ = number.split('')).length; i$ < len$; ++i$) {
    digit = ref$[i$];
    if (zhwordmap[digit] != null) {
      digit = zhwordmap[digit];
    }
    if (digit in zhmap) {
      tmp = zhmap[digit];
    } else if (in$(digit, commitword)) {
      result += (buffer + tmp) * zhmap10[digit];
      buffer = 0;
      tmp = 0;
    } else {
      if (digit === '十' && tmp === 0) {
        tmp = 1;
      }
      buffer += tmp * zhmap10[digit];
      tmp = 0;
    }
  }
  return result + buffer + tmp;
};
module.exports = {
  parseZHNumber: parseZHNumber
};
function in$(x, arr){
  var i = -1, l = arr.length >>> 0;
  while (++i < l) if (x === arr[i] && i in arr) return true;
  return false;
}
});
