package org.lsst.camera.portal.utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.SortedMap;
import javax.servlet.jsp.jstl.sql.Result;

/**
 * File handling utilities for the data portal
 *
 * @author tonyj
 */
public class FileUtils {

    private static final String FILE_DELIM = "/";

    /**
     * Extract a List from a single column of a result set
     *
     * @param query The result of an sql query
     * @param column The column to extract
     * @return The extracted list.
     */
    public static List getColumnFromResult(Result query, String column) {
        List result = new ArrayList<>();
        for (SortedMap row : query.getRows()) {
            result.add(row.get(column));
        }
        return result;
    }

    /**
     * Find the common root of a list of files
     *
     * @param files A list of files
     * @return The common root
     */
    public static String commonRoot(List files) {
        String result = null;
        for (Object path : files) {
            String file = path.toString();
            if (result == null) {
                result = file;
            } else if (!file.startsWith(result)) {
                List<String> split = Arrays.asList(file.split(FILE_DELIM));
                for (int i = split.size(); i > 0; i--) {
                    String join = join(FILE_DELIM, split.subList(0, i));
                    if (result.startsWith(join)) {
                        result = join + FILE_DELIM;
                        break;
                    }
                }
            }
        }
        return result == null ? "" : result;
    }

    public static String relativize(String root, String file) {
        return file.startsWith(root) ? file.substring(root.length()) : file;
    }

    private static String join(String delim, List<String> list) {
        //Java 8
        //return String.join(delim,list);
        if (list.isEmpty()) return "";
        StringBuilder result = new StringBuilder();
        for (String element : list) {
            result.append(element).append(delim);
        }
        return result.substring(0, result.length()-1);
    }
    
    public static String fileType(String file) {
        int pos = file.lastIndexOf('.');
        if (pos<0) return "";
        else {
            String type = file.substring(pos+1);
            return type.toLowerCase();
        }
    }
    
    public static boolean fileTypeIn(String file, String[] list) {
        String type = fileType(file);
        for (String l : list) {
            if (type.equalsIgnoreCase(l)) return true;
        }
        return false;
    }
}
