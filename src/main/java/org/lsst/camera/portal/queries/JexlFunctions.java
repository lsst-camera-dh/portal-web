package org.lsst.camera.portal.queries;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlScript;
import org.apache.commons.jexl3.MapContext;

/**
 * Utility functions for use in JEXL expressions
 *
 * @author tonyj
 */
public class JexlFunctions {

    private static final Pattern webFormat = Pattern.compile("\\%(\\S+)w");
    private static final Pattern numberInBrackets = Pattern.compile("\\[([\\+\\-]?[.0-9]+)(e(\\S+))?\\]");

    private final Map<String, Map<String, List<Object>>> data;
    private final SimpleDateFormat sdf;
    private final JexlEngine jexl;
    private final MapContext mc;

    JexlFunctions(JexlEngine jexl, MapContext mc, Map<String, Map<String, List<Object>>> data) { // constructor
        this.jexl = jexl;
        this.mc = mc;

        this.data = data;
        sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss z");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    public List fetch(String specId) {
        return fetch(specId, "value");
    }

    public List fetch(String specId, String column) {
        final Map<String, List<Object>> specData = data.get(specId);
        if (specData == null) {
            throw new RuntimeException("Unable to fetch " + specId);
        }
        final List result = specData.get(column);
        if (result == null) {
            throw new RuntimeException("Unable to fetch " + specId + " " + column);
        }
        return result;
    }

    public Number min(List<Number> args) {
        Number min = Double.NaN;
        for (Number a : args) {
            if (!(a.doubleValue() > min.doubleValue())) {
                min = a; // if NaN (not-a-number or not a mathematical result) is false then it's a number and greater than min, so reset min to a 
            }
        }
        return min;
    }

    public Number max(List<Number> args) {
        Number max = Double.NaN;
        for (Number a : args) {
            if (!(a.doubleValue() < max.doubleValue())) {
                max = a;
            }
        }
        return max;
    }

    public int minIndex(List<Number> args) {
        double min = Double.NaN;
        int minIndex = -1;
        for (int i = 0; i < args.size(); i++) {
            double a = args.get(i).doubleValue();
            if (!(a > min)) {
                min = a;
                minIndex = i;
            }
        }
        return minIndex;
    }

    public int maxIndex(List<Number> args) {
        double max = Double.NaN;
        int maxIndex = -1;
        for (int i = 0; i < args.size(); i++) {
            double a = args.get(i).doubleValue();
            if (!(a < max)) {
                max = a;
                maxIndex = i;
            }
        }
        return maxIndex;
    }

    public List<Number> mergeArrays(List<Number> a1, List<Number> a2) {
        // given two arrays merge them into one list to be used by the measurement statement in REPORT_SPECS.
        List<Number> mergedList = new ArrayList<>();
        mergedList.addAll(a1);
        mergedList.addAll(a2);

        return mergedList;
    }

    public List<Number> string2array(String stringOfnumbers) {
        String[] nums = stringOfnumbers.split(",");
        List<Number> arrNums = new ArrayList<>();
        for (String n : nums) {
            double newNum = Double.parseDouble(n);
            arrNums.add(newNum);
        }
        return arrNums;
    }

    public String formatUnixtime2UTC(double utime) {
        Date longdate = new Date((long) (utime * 1000));
        String newTime = sdf.format(longdate);
        return newTime;
    }

    public List<Number> divide(List<Number> a1, List<Number> a2) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < Math.min(a1.size(), a2.size()); i++) {
            result.add(a1.get(i).doubleValue() / a2.get(i).doubleValue());
        }
        return result;
    }

    public List<Number> multiply(List<Number> a1, List<Number> a2) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < Math.min(a1.size(), a2.size()); i++) {
            result.add(a1.get(i).doubleValue() * a2.get(i).doubleValue());
        }
        return result;
    }

    public List<Number> multiply(double scalar, List<Number> a2) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < a2.size(); i++) {
            result.add(scalar * a2.get(i).doubleValue());
        }
        return result;
    }

    public List<Number> pow(List<Number> a2, double power) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < a2.size(); i++) {
            result.add(Math.pow(a2.get(i).doubleValue(), power));
        }
        return result;
    }

    public List<Number> add(List<Number> a1, List<Number> a2) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < Math.min(a1.size(), a2.size()); i++) {
            result.add(a1.get(i).doubleValue() + a2.get(i).doubleValue());
        }
        return result;
    }

    public List<Number> subtract(List<Number> a1, List<Number> a2) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < Math.min(a1.size(), a2.size()); i++) {
            result.add(a1.get(i).doubleValue() - a2.get(i).doubleValue());
        }
        return result;
    }

    public double sum(List<Number> args) {
        double sum = 0;
        for (Number a : args) {
            sum = sum + a.doubleValue();
        }
        return sum;
    }

    public double median(List<Number> args) {
        // Collections does not have a comparator for Number so we have to make our own. 
        List<Number> tmpList = new ArrayList<>(args);
        Collections.sort(tmpList, new Comparator<Number>() {
            @Override
            public int compare(Number o1, Number o2) {
                return (int) Math.signum(o1.doubleValue() - o2.doubleValue());
            }
        });

        int size = tmpList.size();
        boolean isOdd = size % 2 != 0;

        if (isOdd) {
            return tmpList.get(size / 2).doubleValue();
        } else {
            return (tmpList.get(size / 2).doubleValue() + tmpList.get(size / 2 + 1).doubleValue()) / 2;
        }
    }

    public String format(String format, Object... arg) {
        // Note we support a special format %n.nw which is equivalent to %n.ng
        // except that the number is displayed using html superscripts.
        Matcher matcher = webFormat.matcher(format);
        return webify(String.format(matcher.replaceAll("[%$1g]"), arg));
    }

    private String webify(String input) {
        Matcher match = numberInBrackets.matcher(input);
        StringBuffer result = new StringBuffer();
        while (match.find()) {
            if (match.group(3) != null) {
                int exponent = Integer.parseInt(match.group(3));
                match.appendReplacement(result, "$1&times10<sup>" + exponent + "</sup>");
            } else {
                match.appendReplacement(result, "$1");
            }
        }
        match.appendTail(result);
        return result.toString();
    }

    public List<Map<String, Object>> toTable(String[] headers, int nRows, String... jexlCol) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < nRows; i++) {
            Map<String, Object> item = new LinkedHashMap<>();
            for (int j = 0; j < headers.length; j++) {
                mc.set("row", i);
                try {
                    JexlScript func = jexl.createScript(jexlCol[j]);
                    item.put(headers[j], func.execute(mc));
                } catch (Exception x) {
                    item.put(headers[j], "???");
                }
            }
            result.add(item);
        }
        return result;
    }
    
    /**
     * Convert amplified number (1-16) to segment number,
     * Not this map is independent of the type of CCD.
     * @param amp
     * @return 
     */
    public String ampToSegment(int amp) {
        int segment = amp<=8 ? 9+amp : 16-amp;
        return String.format("%02d", segment);
    }
}
